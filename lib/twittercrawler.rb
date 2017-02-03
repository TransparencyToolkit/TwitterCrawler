require 'requestmanager'
require 'selenium-webdriver'
require 'pry'
require 'nokogiri'

load 'twitter_parser.rb'

class TwitterCrawler
  def initialize(search_term, operator, requests)
    @search_term = search_term
    @operator = operator
    @requests = requests
    @output = Array.new
  end

  # Generate advanced query
  def gen_query
    if @operator
      return URI.encode(@search_term + " " + @operator)
    else
      return URI.encode(@search_term)
    end
  end

  def crawl
    @requests.get_page("https://twitter.com/search?f=tweets&q="+gen_query)
    scroll_down(0)
    get_tweets
    @requests.close_all_browsers
  end

  # Get the tweets on the page
  def get_tweets
    browser = @requests.get_most_recent_browser[1].first
    tweets = browser.find_elements(class: "tweet")

    # Parse each tweet
    tweets.each do |tweet|
      tweet_html = tweet.attribute("innerHTML")
      parser = TwitterParser.new(tweet_html)
      @output.push(parser.parse_tweet)
    end
  end

  # Scroll down to the bottom
  def scroll_down(last_tweet_num)
    # Scroll down to last tweet
    browser = @requests.get_most_recent_browser[1].first
    tweets = browser.find_elements(class: "tweet")
    tweets[tweets.length-2].location_once_scrolled_into_view

    # Check if it should be rerun
    sleep(1)
    tweet_count = browser.find_elements(class: "tweet").length
    if tweet_count > last_tweet_num
      scroll_down(tweet_count)
    end   
  end

  # Generate JSON for output
  def gen_json
    JSON.pretty_generate(@output)
  end
end

