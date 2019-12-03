require 'roda'
require 'rss'
require 'json'

DATA_DIR = ENV['CRAWLERS_DATA_DIR']

def produce_rss(events)
  rss = RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'GoOut'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = 'List of just announced events in Prague'
    maker.channel.title = 'GoOut.cz Praha Newly Announced'

    events.each do |event|
      maker.items.new_item do |item|
        item.link = event['link']
        item.title = event['name']
        item.updated = event['scrapeDate']
        item.description = "#{event['dateTime']} - #{event['venue']}"
      end
    end
  end
end

class RssProviderApp < Roda
  route do |r|
    r.on 'goout.rss' do
      response['Content-Type'] = 'application/xml'
      file = File.open "#{DATA_DIR}/goout_newly_announced.json"
      events = JSON.load file
      rss = produce_rss events
      rss.to_s
    end
    r.on do
      '404: Not found'
    end
  end
end
