require 'sinatra'
require 'rss'
require 'json'

DATA_DIR = ENV['CRAWLERS_DATA_DIR']

def produceRSS(events)
  rss = RSS::Maker.make("atom") do |maker|
    maker.channel.author = "GoOut"
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "List of just announced events in Prague"
    maker.channel.title = "GoOut.cz Praha Newly Announced"

    events.each do |event|
      maker.items.new_item do |item|
        item.link = event["link"]
        item.title = event["name"]
        item.updated = event["scrapeDate"]
        item.description = "#{event["dateTime"]} - #{event["venue"]}"
      end
    end
  end
end

class RssProviderApp < Sinatra::Base
  get '/goout.rss', :provides => ['rss', 'atom', 'xml'] do
    file = File.open "#{DATA_DIR}/goout_newly_announced.json"
    events = JSON.load file
    rss = produceRSS events
    rss.to_s
  end
end
