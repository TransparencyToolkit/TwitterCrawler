This is a crawler for Twitter.

To install:
gem install twittercrawler

To include:
require 'twittercrawler'

To run:
t = TwitterCrawler.new("search_term", "since:yyyy-mm-dd (or other operator)", cm_hash or nil)
t.query_tweets(nil, nil)
puts t.gen_json
