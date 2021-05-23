# frozen_string_literal: true

require 'json'

# Will determine if a command has been used.
class Parser
  include Logging
  def initialize(event, command)
    # @args = {} # table to hold the message that was sent.
    @command = command
    @event = event
    @prefix = event.bot.prefix
    @json_file = File.read('data/macros.json')
    @all_macros = JSON.parse(@json_file)
  end

  def parse_macro
    server_macros = @all_macros[@event.server.id.to_s]

    # prefer sensetive case, if nil, then go insenseteive.
    if server_macros[@command].nil?
      # check insensetive case
      insensitive_match = server_macros.keys.grep(/^#{@command}$/i)
      send_macro_text(insensitive_match[0])
    else
      # send sensetive case
      send_macro_text(@command)
    end
  end

  def send_macro_text(command)
    @event.respond @all_macros[@event.server.id.to_s][command]

    logger.info(format('[MACRO] Command: \'%<cmd>s\' was executed by: %<user>s in %<channel>s @ %<discord>s',
                       cmd: @command,
                       user: @event.author.distinct,
                       channel: @event.channel.name,
                       discord: @event.server.name))
  end
end
