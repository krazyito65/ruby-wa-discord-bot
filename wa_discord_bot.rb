# frozen_string_literal: true

require 'discordrb'
require 'yaml'
require 'optparse'
require 'logger'
require 'pp'

require_relative 'helpers/logging'
require_relative 'commands/ping'
require_relative 'commands/macro'
require_relative 'commands/quote'

require_relative 'helpers/macro_parser'
include Logging

options = {}
prefix = '!'
OptionParser.new do |opts|
  opts.banner = 'Usage: wa_discord_bot.rb [options]'

  opts.on('-p', '--prod', "Use the 'Live' token") do |_|
    options[:prod] = true
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

# load the token yml file.
config = YAML.safe_load(File.open('token.yml'))

# set the logger format of our logs.
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
  token = config['live_loken']
else
  logger.level = Logger::DEBUG
  logger.info('Using DEV token.')
  token = config['dev_token']
end

# bot = Discordrb::Bot.new token: token, prefix: '!'
bot = Discordrb::Commands::CommandBot.new token: token, prefix: prefix, ignore_bots: true

# ping command
bot.command(:ping, description: 'Lets you know if the bot is working') do |event|
  Ping.new(event).pong
end

# add logging for the help command
bot.message(start_with: '!help') do |event|
  logger.info(format('[HELP] Responding to a help command in: %<channel>s @ %<discord>s by: %<user>s',
                     channel: event.channel.name,
                     discord: event.server.name,
                     user: event.author.distinct))
end

# quote command
bot.command(:quote, description: 'add a quote for the server, or post a random quote.',
                    usage: 'qutoe [add/remove|delete/edit quote_text]') do |event|
  Quote.new(event).random_quote
end

# macro command
bot.command(:macro, aliases: [:macros],
                    description: 'Can dispaly available macros on the server, or add/delete/edit them.',
                    usage: 'macro [add/remove|delete/edit macro_name macro_text]') do |event, *args|
  if args.empty?
    Macro.new(event).help
    break
  end

  if args.length.eql?(2) && args[0].match(/remove|delete/)
    Macro.new(event, args[0], args[1]).parse
    break
  end

  if args.length < 3
    event.respond 'Not enough parameters'
    event.respond 'Usage: !macro `[add/remove/edit macro_name macro_text]`'
    logger.info(format('[MACRO] Not enough paramters command: \'%<cmd>s\' in: %<channel>s @ %<discord>s by: %<user>s',
                       cmd: event.text,
                       channel: event.channel.name,
                       discord: event.server.name,
                       user: event.author.distinct))
    break
  end

  action = args.shift
  macro_name = args.shift
  macro_text = args.join(' ')

  Macro.new(event, action, macro_name, macro_text).parse unless args.empty?
end

# macro execution
bot.message(start_with: bot.prefix) do |event|
  msg = event.text
  msg[0] = '' # remove the first character (the prefix)
  command = /^\w+/.match(msg).to_s # grab the first word from the text, which is the command
  all_commands = bot.commands.keys.map!(&:to_s) # convert the symbols to strings to compare with

  # fuck off if we're looking for a builtin command
  Parser.new(event, command).parse_macro unless all_commands.include?(command)
end

bot.run
