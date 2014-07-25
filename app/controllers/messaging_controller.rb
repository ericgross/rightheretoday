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

    topics = ["coffee", "tea"]
    client.filter(:track => topics.join(",")) do |object|
      if object.is_a?(Twitter::Tweet)
        response.stream.write "data: #{object.text}\n\n"
      else
        response.stream.write "data: #{object.inspect}\n\n"
      end
    end

  ensure
    response.stream.close
  end
end
