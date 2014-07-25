class NearbyController < ApplicationController
  def index
=begin
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = "wU8W1AIcKGaPWFxRbrnbUkiA4"
      config.consumer_secret = "IbqCk0VOjgo8G1SOiTt25U6B470986N4rGRHitSjg97ASMdz6v"
    end

    stream = Twitter::Streaming::Client.new do |config|
      config.consumer_secret = "IbqCk0VOjgo8G1SOiTt25U6B470986N4rGRHitSjg97ASMdz6v"
      config.consumer_key    = "wU8W1AIcKGaPWFxRbrnbUkiA4"
      config.access_token = "16500296-CMk2BzxkYBzLl7aXTyfzG9lc6usc6d8pdO0xzfysC"
      config.access_token_secret = "ay4av6fQN1kZ3oEJ7OqCzfBDTnliGrs4X8VSoZpkFrwkr"
    end

    location = params[:location]
    query = "geocode:#{location},1mi"
    tweets = client.search(query, :result_type => "recent")
    @results = Array.new
    tweets.each do |tweet|
      if !@results.any?{|t| t.text == tweet.text}
        @results << tweet
      end
      if @results.count > 20
        break
      end
    end
=end
  end
end
