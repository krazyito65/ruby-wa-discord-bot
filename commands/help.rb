# frozen_string_literal: true

# NOT NEEDED ANY MORE.  LIB HANDLES THIS.

# Class to show Help command for bot usage.
class Help
  include Logging
  def initialize(event, prefix)
    @event = event
    @commands = %w[ping help macro]
    @prefix = prefix
  end

  def print_help
    logger.info(format('[HELP] Responding to a help command in: %<channel>s @ %<discord>s by: %<user>s',
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))
    @commands = @commands.sort
    return_string = "List of current commands:\n"
    @commands.each do |cmd|
      cmd = 'help [macros|quotes]' if cmd.eql?('help')

      return_string += "\t#{@prefix}#{cmd}\n"
    end

    @event.respond return_string
  end

  def print_macros
    logger.info(format('[HELP] Listing current macros in: %<channel>s @ %<discord>s by: %<user>s',
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))
    # @event.respond "You can find the macros here: http://bot.weakauras.wtf/" + serverID
  end
end
