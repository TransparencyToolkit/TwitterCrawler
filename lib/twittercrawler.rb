require 'requestmanager'
require 'selenium-webdriver'
require 'pry'
require 'nokogiri'
require 'curb'

load 'twitter_parser.rb'

class TwitterCrawler
  def initialize(search_term, operator, cm_hash)
    @search_term = search_term
    @operator = operator
    @output = Array.new

    # Handle crawler manager info
    @cm_url = cm_hash[:crawler_manager_url] if cm_hash
    @selector_id = cm_hash[:selector_id] if cm_hash
  end

  # Generate advanced query
  def gen_query
    if @operator
      return URI.encode(@search_term + " " + @operator)
    else
      return URI.encode(@search_term)
    end
  end

  # Parse the tweets into html
  def parse_tweets(tweets)
    return tweets.map do |tweet|
      parser = TwitterParser.new(tweet.to_html)
      parser.parse_tweet
    end
  end

  # Generate the query url for Twitter
  def gen_query_url(start_tweet, end_tweet)
    # Base query url
    query_url = "https://twitter.com/i/search/timeline?f=tweets&vertical=news&q="+gen_query+"&src=typd&include_available_features=1&include_entities=1"

    # Gen query URL
    if start_tweet && end_tweet
      query_url += "&max_position=TWEET-"+start_tweet+"-"+end_tweet
    end
    return query_url
  end

  # Query tweets
  def query_tweets(start_tweet, end_tweet)
    # Run Query and parse results
    c = Curl::Easy.perform(gen_query_url(start_tweet, end_tweet))
    curl_items = JSON.parse(c.body_str)
    tweets = Nokogiri::HTML.parse(curl_items["items_html"]).css(".tweet") if curl_items["items_html"]

    # Save results
    parsed_tweets = parse_tweets(tweets)
    report_results(parsed_tweets, parsed_tweets.length.to_s+" tweets")
    
    # Recurse when needed
    if !parsed_tweets.empty?
      start_tweet, end_tweet = get_tweet_range(parsed_tweets, end_tweet)
      query_tweets(start_tweet, end_tweet)
    end
  end

  # Get the ID for a tweet
  def get_tweet_id(tweet)
    return tweet[:tweet_link].split("/").last
  end
  
  # Get start and end tweets
  def get_tweet_range(parsed_tweets, end_tweet)
    if end_tweet # Keeep latest tweet as same
      return get_tweet_id(parsed_tweets.last), end_tweet
    else # Get updated start tweet
      return get_tweet_id(parsed_tweets.last), get_tweet_id(parsed_tweets.first)
    end
  end

  # Figure out how to report results
  def report_results(results, link)
    if @cm_url
      report_incremental(results, link)
    else
      report_batch(results)
    end
  end

  # Report all results in one JSON
  def report_batch(results)
    results.each do |result|
      @output.push(result)
    end
  end

  # Report results back to Harvester incrementally
  def report_incremental(results, link)
    curl_url = @cm_url+"/relay_results"
    c = Curl::Easy.http_post(curl_url,
                             Curl::PostField.content('selector_id', @selector_id),
                             Curl::PostField.content('status_message', "Collected " + link),
                             Curl::PostField.content('results', JSON.pretty_generate(results)))
  end

  # Generate JSON for output
  def gen_json
    JSON.pretty_generate(@output)
  end
end


