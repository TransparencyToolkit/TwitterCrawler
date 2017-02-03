This is a crawler for Twitter.

To install:
gem install twittercrawler

To include:
require 'twittercrawler'
require 'requestmanager'

To run:
requests = RequestManager.new(nil, [1, 3], 1)
t = TwitterCrawler.new("search_term", "since:yyyy-mm-dd (or other operator)",
requests, cm_hash or nil)
t.crawl
puts t.gen_json
