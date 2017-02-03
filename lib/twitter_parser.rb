require 'nokogiri'
require 'pry'

class TwitterParser
  def initialize(tweet)
    @tweet = Nokogiri::HTML.parse(tweet)
  end

  # Parse the individual tweet
  def parse_tweet
    if !@tweet.text.empty?
      return {
        tweet_text: get_tweet_text,
        username: get_username,
        fullname: get_fullname,
        user_id: get_user_id,
        reply_to_user: get_reply_to_user[0],
        reply_to_uid: get_reply_to_user[1],
        tweet_time: get_tweet_time,
        tweet_link: get_tweet_link,
        retweet_count: get_retweet_count,
        favorite_count: get_favorite_count,
        reply_count: get_reply_count,
        mention_names: get_mentions[0],
        mention_uids: get_mentions[1]
      }
    end
  end

  # Get the username
  def get_username
    @tweet.css(".username").text
  end

  # Get the fullname
  def get_fullname
    @tweet.css(".fullname").text
  end

  # Get user ID number
  def get_user_id
    @tweet.css(".js-user-profile-link").css(".account-group")[0]["data-user-id"]
  end

  # Get the tweet text
  def get_tweet_text
    @tweet.css(".js-tweet-text-container").text.lstrip.strip
  end

  # Get the time for the tweet
  def get_tweet_time
    DateTime.parse(@tweet.css(".tweet-timestamp")[0]["title"]).strftime('%d %b %Y %H:%M:%S')
  end

  # Get the link to the tweet
  def get_tweet_link
    "https://twitter.com"+@tweet.css(".tweet-timestamp")[0]['href']
  end

  # Get the # of retweets
  def get_retweet_count
    @tweet.css(".ProfileTweet-action--retweet")[0].css("span")[0]['data-tweet-stat-count']
  end

  # Get the # of favorites
  def get_favorite_count
    @tweet.css(".ProfileTweet-action--favorite")[0].css("span")[0]['data-tweet-stat-count']
  end

  # Get the # of replies
  def get_reply_count
    @tweet.css(".ProfileTweet-action--reply")[0].css("span")[0]['data-tweet-stat-count']
  end

  # Get the user tweet is replying to (if any)
  def get_reply_to_user
    reply_to = @tweet.css("span").select{|s| s.text.include?("In reply")}[0]
    if reply_to
      reply_to_user = reply_to.css("a")[0]['href'].gsub("/", "@")
      reply_to_uid = reply_to.css("a")[0]['data-user-id']
      return reply_to_user, reply_to_uid
    else
      return nil, nil
    end
  end

  # Get the mentioned accounts (if any)
  def get_mentions
    mentions = @tweet.css(".twitter-atreply")
    if !mentions.empty?
      mention_names = mentions.map{|t| t.text}
      mention_uids = mentions.map{|t| t['data-mentioned-user-id']}
      return mention_names, mention_uids
    else
      return nil, nil
    end
  end
end
