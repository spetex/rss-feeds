require 'roda'
require 'rss'
require 'json'

DATA_DIR = ENV['CRAWLERS_DATA_DIR']

def create_event(event, maker)
  maker.items.new_item do |item|
    item.link = event['link']
    item.title = event['name']
    item.updated = event['scrapeDate']
    item.description = "#{event['dateTime']} - #{event['venue']}"
  end
end

def produce_goout_rss(events, category)
  RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'GoOut'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "List of just announced #{category} in Prague"
    maker.channel.title = "#{category.capitalize} - GoOut.cz Praha Newly Announced"

    events.each { |event| create_event(event, maker) }
  end
end

def create_post(post, maker)
  maker.items.new_item do |item|
    item.link = post['link']
    item.title = post['name']
    item.updated = post['scrapeDate']
  end
end

def produce_puttyandpaint_rss(posts, category)
  RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'PuttyAndPaint.com'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "List of #{category} on PuttyAndPaint"
    maker.channel.title = "#{category.capitalize} - PuttyAndPaint.com"

    posts.each { |post| create_event(post, maker) }
  end
end

def produce_coolminiornot_rss(posts)
  RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'CoolMiniOrNot.com'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "Gallery on CoolMiniOrNot"
    maker.channel.title = "Gallery - CoolMiniOrNot.com"

    posts.each { |post| create_event(post, maker) }
  end
end

def produce_whcommunity_rss(posts, category)
  RSS::Maker.make('atom') do |maker|
    maker.channel.author = 'Warhammer Community'
    maker.channel.updated = Time.now.to_s
    maker.channel.about = "List of #{category} on Warhammer Community"
    maker.channel.title = "#{category.capitalize} - WarhammerCommunity"

    posts.each { |post| create_event(post, maker) }
  end
end

class RssProviderApp < Roda
  route do |r|
    r.on 'goout.rss' do
      response['Content-Type'] = 'application/xml'
      file = File.read "#{DATA_DIR}/events_goout_newly_announced.json"
      events = JSON.parse file
      rss = produce_rss events 'Master'
      rss.to_s
    end

    r.on 'goout', String do |category|
      response['Content-Type'] = 'application/xml'
      file = File.read "#{DATA_DIR}/#{category}_goout_newly_announced.json"
      events = JSON.parse file
      rss = produce_goout_rss events, category
      rss.to_s
    end

    r.on 'puttyandpaint', String do |category|
      response['Content-Type'] = 'application/xml'
      file = File.read "#{DATA_DIR}/#{category}_puttyandpaint.json"
      posts = JSON.parse file
      rss = produce_puttyandpaint_rss posts, category
      rss.to_s
    end

    r.on 'whcommunity', String do |category|
      response['Content-Type'] = 'application/xml'
      file = File.read "#{DATA_DIR}/#{category}_whcommunity.json"
      posts = JSON.parse file
      rss = produce_whcommunity_rss posts, category
      rss.to_s
    end

    r.on 'coolminiornot' do
      response['Content-Type'] = 'application/xml'
      file = File.read "#{DATA_DIR}/coolminiornot.json"
      posts = JSON.parse file
      rss = produce_coolminiornot_rss posts
      rss.to_s
    end

    r.on do
      '404: Not found'
    end
  end
end
