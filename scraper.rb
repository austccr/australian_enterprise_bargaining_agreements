# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'mechanize'

def new_agreement
  {
    reference_number: nil,
    attached_document_url: nil,
    attached_document_syndicated_url: nil,
    title: nil,
    type: nil,
    code_description: nil,
    created_at: nil,
    modified_at: nil,
    details: nil,
    publication_id: nil,
    old_pub_code: nil,
    original_dispute_number: nil,
    version: nil,
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
      agreement[:created_at] = value
    when "Last Modified Date: "
      agreement[:modified_at] = value
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

# INDEX_URL = "https://www.fwc.gov.au/search/document/agreement?items_per_page=100"

agent = Mechanize.new

# page = agent.get(INDEX_URL)

# agreement_links = page.links.select {|l| l.text.eql? 'More info' }

# For each | test with first
# agreement_page = agreement_links.first.click

agreement_page  = agent.get('https://www.fwc.gov.au/document/agreement/AE502436')
agreement = new_agreement

table = agreement_page.at('#block-system-main')

agreement[:reference_number] = agreement_page.uri.path.split('/').last

puts "Collecting EBA #{agreement_page[:reference_number]}"

agreement[:attached_document_url] = table.at('.field-name-field-fwc-doc-pdf-file a')[:href]
agreement[:title] = agreement_page.at('#page-title').text

agreement = assign_detail_fields(
  table.at('.entity-fwc-agreement').search('.field'),
  agreement
)

ScraperWiki.save_sqlite([:reference_number], agreement)
puts "Saved EBA #{agreement_page[:reference_number]}"

#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
