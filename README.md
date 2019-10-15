This is a scraper that runs on [Morph](https://morph.io). To get started [see the documentation](https://morph.io/documentation)

## Configuration

Use the env variable `MORPH_STOP_AFTER` to make the scraper stop running after after
it's been through x number of pages without finding any new records to record.

```
MORPH_STOP_AFTER=10 bundle exec ruby scraper.rb
```

Use the env variable `MORPH_START_PAGE` to set which page in the pagination to start
from:

```
MORPH_START_PAGE=10 bundle exec ruby scraper.rb
```

## Questions

* [x] What about updates?
      For now we should skip what we have I think, based on URL.
      In the future we might like to check if there's been updates and update what we have.
* [ ] Is it useful to preserve 'N/A' values, or should they be skipped/left empty?
* [ ] Where does 'Member name' come from?
