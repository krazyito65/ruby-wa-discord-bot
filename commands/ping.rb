# frozen_string_literal: true

# Basic Ping class to see if bot is working.
class Ping
  include Logging
  def initialize(event)
    @event = event
  end

  def pong
    logger.info(format('[PING] Responding to a ping in: %<channel>s @ %<discord>s by: %<user>s',
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))
    @event.respond "Pong! Bot appears to be working.
    \tInvite link: <#{@event.bot.invite_url}>
    \tGithub: <https://github.com/krazyito65/ruby-wa-discord-bot>"
  end
end
