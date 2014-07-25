class MessagingController < ApplicationController
  include ActionController::Live

  def send_message
    response.headers['Content-Type'] = 'text/event-stream'

    client = Twitter::Streaming::Client.new do |config|
      config.consumer_secret = "IbqCk0VOjgo8G1SOiTt25U6B470986N4rGRHitSjg97ASMdz6v"
      config.consumer_key    = "wU8W1AIcKGaPWFxRbrnbUkiA4"
      config.access_token = "16500296-CMk2BzxkYBzLl7aXTyfzG9lc6usc6d8pdO0xzfysC"
      config.access_token_secret = "ay4av6fQN1kZ3oEJ7OqCzfBDTnliGrs4X8VSoZpkFrwkr"
    end

    start = {lat: 40.713938, lng: -73.9790146}
    box_size = 0.1
    box = [start[:lng] - box_size, start[:lat] - box_size, start[:lng] + box_size, start[:lat] + box_size]
    client.filter(locations: box.join(',')) do |object|
      if object.is_a?(Twitter::Tweet)
        store_tweet(object)
        score = tweet_score(object)
        object_data = {text: "#{score} #{object.text}", score: tweet_score(object)}
        response.stream.write "data: #{object_data.to_json}\nretry: 10000\n\n"
      else
        response.stream.write "data: #{object.inspect.to_json}\nretry: 10000\n\n"
      end
    end

  ensure
    response.stream.close
  end

  def redis
    @redis ||= Redis.new
  end

  def store_tweet(tweet)
    redis.pipelined do
      tweet.text.split(' ').each do |word|
        redis.incr("word:#{word}")
      end
    end
  end

  def tweet_score(tweet)
    redis.pipelined do
      tweet.text.split(' ').reject{|word| word.length < 4}.each do |word|
        redis.get("word:#{word}")
      end
    end.max
  end
end
