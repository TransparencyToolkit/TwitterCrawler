require 'nokogiri'
require 'pry'
require 'twitter-text'

class TwitterParser
  include Twitter::Extractor
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
        profile_pic: get_profile_pic,
        hashtags: get_hashtags,
        mentioned_urls: get_mentioned_urls,
        conversation_id: get_conversation_id,
        is_reply_to: get_is_reply_to,
        reply_to_user: get_reply_to_user[0],
        reply_to_uid: get_reply_to_user[1],
		tweet_id: get_tweet_id,
        tweet_time: get_tweet_time,
        tweet_link: get_tweet_link,
        retweet_count: get_retweet_count,
        favorite_count: get_favorite_count,
        reply_count: get_reply_count,
        mention_names: get_mentions[0],
        mention_uids: get_mentions[1],
        time_collected: Time.now,
        date_searchable: get_tweet_time
      }
    end
  end

  # Get URL to the profile pic
  def get_profile_pic
    @tweet.css("img.avatar")[0]['src']
  end

  # Get URLS in the tweet
  def get_mentioned_urls
    tweet = get_tweet_text
    return extract_urls(tweet)
  end

  # Get hashtags in the tweet
  def get_hashtags
    tweet = get_tweet_text
    return extract_hashtags(tweet)
  end

  def get_username
	@tweet.css(".tweet")[0]["data-screen-name"]
  end

  def get_fullname
    @tweet.css(".fullname").text
  end

  def get_user_id
    @tweet.css(".js-user-profile-link").css(".account-group")[0]["data-user-id"]
  end

  # Get the tweet text
  def get_tweet_text
    @tweet.css(".js-tweet-text-container").text.lstrip.strip
  end

  # Get the time of the tweet
  def get_tweet_time
    DateTime.parse(@tweet.css(".tweet-timestamp")[0]["title"]).strftime('%d %b %Y %H:%M:%S')
  end

  def get_tweet_id
	@tweet.css(".tweet")[0]["data-tweet-id"]
  end

  def get_tweet_link
    "https://twitter.com"+@tweet.css(".tweet")[0]["data-permalink-path"]
  end

  def get_retweet_count
    @tweet.css(".ProfileTweet-action--retweet")[0].css("span")[0]['data-tweet-stat-count']
  end

  def get_favorite_count
    @tweet.css(".ProfileTweet-action--favorite")[0].css("span")[0]['data-tweet-stat-count']
  end

  def get_conversation_id
	@tweet.css(".tweet")[0]["data-conversation-id"]
  end

  def get_is_reply_to
    @tweet.css(".tweet")[0]["data-is-reply-to"]
  end

  def get_reply_count
    @tweet.css(".ProfileTweet-action--reply")[0].css("span")[0]['data-tweet-stat-count']
  end

  # The user of the tweet that is being replied to (if any)
  def get_reply_to_user
    reply_to = @tweet.css("span").select{|s| s.text.include?("In reply")}[0]
    if reply_to
      reply_to_user = reply_to.css("a")[0]['href'].gsub("/", "")
      reply_to_uid = reply_to.css("a")[0]['data-user-id']
      return reply_to_user, reply_to_uid
    else
      return nil, nil
    end
  end

  # Get account names and uids that are mentioned
  def get_mentions
    mentions = @tweet.css(".twitter-atreply")
    if !mentions.empty?
      mention_names = mentions.map{|t| t.css("b").text}
      mention_uids = mentions.map{|t| t['data-mentioned-user-id']}
      return mention_names, mention_uids
    else
      return nil, nil
    end
  end
end
