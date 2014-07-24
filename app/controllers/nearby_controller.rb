class NearbyController < ApplicationController
  def index
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = "wU8W1AIcKGaPWFxRbrnbUkiA4"
      config.consumer_secret = "IbqCk0VOjgo8G1SOiTt25U6B470986N4rGRHitSjg97ASMdz6v"
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
  end
end
