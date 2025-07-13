# frozen_string_literal: true

# basic irb script to get methods from bot
# load './irb-help.rb'

require 'discordrb'
require 'yaml'

config = YAML.safe_load(File.open('token.yml'))
token = config['dev_token']

bot = Discordrb::Commands::CommandBot.new token: token, prefix: '!', ignore_bots: true

# main_event = nil

bot.message(start_with: bot.prefix) do |_event|
  # main_event = event
  puts 'got the event'
  bot.stop
end

bot.run
