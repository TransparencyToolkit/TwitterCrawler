TwitterCrawler
==============

This is a crawler for Twitter data

## Installing

```
gem install twittercrawler
```

## Usage

Include the gem in your Ruby code:

```
require 'twittercrawler'
```

Perform a query to Twitter search API with `search_term` and the date parameter 
`since:2017-02-20`

```
t = TwitterCrawler.new("search_term", "since:yyyy-mm-dd)", cm_hash or nil)
t.query_tweets(nil, nil)
puts t.gen_json
```

You can use any filter parameters that you can use in Twitter's [Advanced
Search](https://twitter.com/search-advanced) interface.
