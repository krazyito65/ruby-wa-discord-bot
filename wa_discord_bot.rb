# frozen_string_literal: true

require 'discordrb'
require 'yaml'
require 'optparse'
require 'logger'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: wa_discord_bot.rb [options]'

  opts.on('-p', '--prod', "Use the 'Live' token") do |_p|
    options[:prod] = true
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

# load the token yml file.
config = YAML.safe_load(File.open('token.yml'))

# set where the logger should print to and format our logs.
logger = Logger.new(STDOUT)
logger.formatter = Logger::Formatter.new
logger.formatter = proc do |severity, datetime, _, msg|
  "#{datetime} - #{severity}: #{msg.dump}\n"
end

# checks if we should use the live token or not
# If no known arguments are passed in, then we will assume DEV.
# Also set logger level.
if options[:prod]
  logger.level = Logger::INFO
  logger.info('Using Live token.')
  token = config['live_token']
else
  logger.level = Logger::DEBUG
  logger.info('Using DEV token.')
  token = config['dev_token']
end

bot = Discordrb::Bot.new token: token

bot.message(with_text: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.run
