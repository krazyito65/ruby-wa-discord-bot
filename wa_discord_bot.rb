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
require_relative 'commands/role'
require_relative 'commands/timestamp'

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
google_api_key = config['google_api_key']

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

# timestamp command
bot.command(:time, aliases: [:timestamp],
                   description: 'Will provide an embed with your local timestamp based on given time.') do |event, *args|
  Timestamp.new(event, google_api_key).post_embed(args.join(' '))
end

# role command
bot.command(:role, aliases: [:roles],
                   description: 'Gives class, hex or alpha roles',
                   usage: 'role [discord_role/remove/hex] [hex_code]') do |event, *args|
  if args.empty?
    Role.new(event).help
    break
  end

  if args[0].downcase.eql?('hex')
    Role.new(event).hex(args[1])
    break
  end

  if args[0].downcase.eql?('remove')
    _r = args.shift
    Role.new(event).remove_role(args.join(' '))
    break
  end

  Role.new(event).parse(args.join(' '))
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
                    description: 'Can display available macros on the server, or add/delete/edit them.',
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
  msg = event.text.split[0]
  msg[0] = '' # remove the first character (the prefix)
  all_commands = bot.commands.keys.map(&:to_s) # convert the symbols to strings to compare with

  # fuck off if we're looking for a builtin command
  Parser.new(event, msg).parse_macro unless all_commands.include?(msg)
end

bot.run
