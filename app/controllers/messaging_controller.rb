class MessagingController < ApplicationController
  include ActionController::Live
  require 'tweetstream'

  def send_message
    response.headers['Content-Type'] = 'text/event-stream'

    client = TweetStream::Client.new

    if params[:lat]
      start = Geokit::LatLng.new(params[:lat].to_f, params[:lng].to_f)
    else
      start = Geokit::LatLng.new(40.713938, -73.9790146)
    end

    box_size = 1
    box = [start.lng - box_size, start.lat - box_size, start.lng + box_size, start.lat + box_size]

    puts "Starting stream for #{box}"

    EM.run do

      client.on_error do |error|
        puts "TweetStreem Error: #{error}"
      end

      client.locations(box) do |object|
        begin
          if object.is_a?(Twitter::Tweet)
            store_tweet(object)
            score = tweet_score(object)
            location = Geokit::LatLng.new(object.geo.lat, object.geo.long)
            distance = start.distance_to(location)

            object_data = {
              text: "#{score} : #{distance} : #{object.text}",
              distance: distance,
              score: tweet_score(object),
            }

            puts object_data.inspect
            response.stream.write "data: #{object_data.to_json}\nretry: 10000\n\n"
          else
            response.stream.write "data: #{object.inspect.to_json}\nretry: 10000\n\n"
          end
        rescue => error
          puts "Error in stream: #{error.message}: #{error.backtrace}"
          response.stream.close
        end
      end

    end

  rescue => error
    binding.pry
  ensure
    begin
      client.stop if client
    rescue
    end
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
