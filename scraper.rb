require 'scraperwiki'
require 'mechanize'

def new_agreement
  {
    reference_number: nil,
    version: 'Not listed',
    url: nil,
    attached_document_url: nil,
    title: nil,
    type: nil,
    code_description: nil,
    created_at: nil,
    modified_at: nil,
    publication_id: nil,
    old_pub_code: nil,
    original_dispute_number: nil,
    industry: nil,
    legal_name: nil,
    trading_name: nil,
    abn: nil,
    state: nil,
    matter_title: nil,
    prefixed_print_id: nil,
    print: nil,
    scraped_at: Time.now.utc.to_s
  }
end

def assign_detail_fields(detail_fields, agreement)
  return agreement unless detail_fields

  detail_fields.map {|f| f.children.map(&:text) }.each do |label, value|
    case label
    when "Agreement Type description: "
      agreement[:type] = value
    when "Agreement Code description: "
      agreement[:code_description] = value
    when "Industry: "
      agreement[:industry] = value
    when "Old Pub Code: "
      agreement[:old_pub_code] = value
    when "Original Dispute Number: "
      agreement[:original_dispute_number] = value
    when "Publication ID: "
      agreement[:publication_id] = value
    when "Version: "
      agreement[:version] = value
    when "State: "
      agreement[:state] = value
    when "ABN: "
      agreement[:abn] = value
    when "Legal Name: "
      agreement[:legal_name] = value
    when "Trading Name: "
      agreement[:trading_name] = value
    when "Created Date: "
      unless value.eql? "N/A"
        agreement[:created_at] = Time.parse(value).strftime("%F %H:%M")
      end
    when "Last Modified Date: "
      unless value.eql? "N/A"
        agreement[:modified_at] = Time.parse(value).strftime("%F %H:%M")
      end
    when "Matter Title: "
      agreement[:matter_title] = value
    when "Prefixed Print ID: "
      agreement[:prefixed_print_id] = value
    when "Print: "
      agreement[:print] = value
    end
  end

  agreement
end

def collect_agreement_from_page(agreement_page)
  agreement = new_agreement
  agreement[:url] = agreement_page.uri.to_s
  agreement[:reference_number] = agreement_page.uri.path.split('/').last
  puts "Collecting EBA #{agreement[:reference_number]} from #{agreement_page.uri.to_s}"

  table = agreement_page.at('#block-system-main')
  agreement[:attached_document_url] = table.at('.field-name-field-fwc-doc-pdf-file a')&.[](:href)
  agreement[:title] = agreement_page.at('#page-title').text

  agreement = assign_detail_fields(
    table.at('.entity-fwc-agreement')&.search('.field'),
    agreement
  )

  ScraperWiki.save_sqlite([:reference_number, :version], agreement)
  sleep 0.1
end

def scrape_index_page(index_page)
  puts
  puts
  puts "Index page #{index_page.uri.to_s}"
  puts

  index_page.links.select {|l| l.text.eql? 'More info' }.each do |link|
    # Skip if we've already scraped this page
    # TODO: Check if there is data we can update from the index page listing?
    if (ScraperWiki.select("* FROM data WHERE url='#{link.href}'").last rescue nil)
      puts "Skipping #{link.href}, already saved"
    else
      collect_agreement_from_page(link.click)
    end
  end
end

def scrape_index_page_and_next(index_page)
  scrape_index_page(index_page)

  next_link = index_page.links.select {|l| l.text.eql? "next ›" }.pop
  scrape_index_page_and_next(next_link.click) if next_link
end

INDEX_URL = "https://www.fwc.gov.au/search/document/agreement?items_per_page=100"

agent = Mechanize.new
scrape_index_page_and_next(agent.get(INDEX_URL))
