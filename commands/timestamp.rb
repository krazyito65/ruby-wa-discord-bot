# frozen_string_literal: true

require 'geokit'
require 'timezone'
require 'active_support/time'
require 'json'

# Class will parse a given time and post an embed with local timezone
class Timestamp
  include Logging
  def initialize(event, api_key)
    @event = event
    Geokit::Geocoders::GoogleGeocoder.api_key = api_key
    Timezone::Lookup.config(:google) do |c|
      c.api_key = api_key
    end
  end

  def post_embed(input)
    location = Geokit::Geocoders::GoogleGeocoder.geocode(input) # get the location of the input

    begin
      timezone = Timezone.lookup(location.lat, location.lng) # get the timezone of the location
    rescue Timezone::Error::InvalidZone
      @event.respond('Invalid location, no timezone found.')
      return
    end

    t = Time.parse(input) # parse the input, will be in local time of the server
    time_input = t.strftime('%F %T.%N').in_time_zone(timezone.name) # change the timezone to be the location that we found.
    embed_time = time_input.utc.strftime('%Y-%m-%dT%H:%M:%S.%NZ') # YYYY-MM-DDTHH:MM:SS.NNNZ

    embed_hash = { embeds: [{ description: "#{input} from #{@event.author.distinct}", timestamp: embed_time }] }
    embed = Discordrb::Webhooks::Embed.new(description: "#{input}", timestamp: time_input)
    # embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'meew0', url: 'https://github.com/meew0', icon_url: 'https://avatars2.githubusercontent.com/u/3662915?v=3&s=466')

    # initialize(title: nil, description: nil, url: nil, timestamp: nil, colour: nil, color: nil, footer: nil, image: nil, thumbnail: nil, video: nil, provider: nil, author: nil, fields: [])

    logger.info(format('[TIME] Responding to a timestamp request in in: %<channel>s @ %<discord>s by: %<user>s',
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))

    @event.respond(nil, nil, embed)
  end
end
