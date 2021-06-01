# frozen_string_literal: true

# Gives class or alpha roles
class Role
  include Logging
  def initialize(event)
    @event = event
    @valid_roles = %w[Druid Death\ Knight Demon\ Hunter Hunter Mage Monk Paladin Priest Rogue Shaman Warlock Warrior WAalpha]
    @server_roles = @event.server.roles.map { |r| [r.name, r.id] }.to_h
  end

  def add_role(role, hex)
    begin
      @event.author.add_role(role)
    rescue Discordrb::Errors::NoPermission
      @event.respond 'The bot does not have permisson to add the role.'
      logger.warn(format('[ROLE] Bot does not have permissons to add role in: %<channel>s @ %<discord>s',
                         channel: @event.channel.name,
                         discord: @event.server.name))
      return
    end
    logger.info(format('[ROLE] Added role %<role>s to %<user>s in %<channel>s @ %<discord>s',
                       role: hex,
                       user: @event.author.distinct,
                       channel: @event.channel.name,
                       discord: @event.server.name))
    @event.respond "Added role: `#{hex}` to #{@event.author.mention}"
  end

  def hex(hex)
    hex = '' if hex.nil? || hex.empty?
    hex.slice!(0) if hex.length.eql?(7) # remove the first character

    unless /^[0-9A-F]+$/i.match?(hex)
      logger.info(format('[ROLE] %<user>s provided invalid hex "#%<hex>s" in %<channel>s @ %<discord>s',
                         hex: hex,
                         user: @event.author.distinct,
                         channel: @event.channel.name,
                         discord: @event.server.name))
      @event.respond "##{hex} is not a valid hex. Please provide a valid hex code."
      return
    end

    if @server_roles.keys.include?(hex)
      add_role(@server_roles[hex], hex)
    else
      color = Discordrb::ColourRGB.new(hex)
      # Discordrb::Permissions.new [:read_messages, :connect, :speak, :read_message_history]
      new_role = @event.server.create_role(name: hex, colour: color, permissions: 3_212_288, reason: "created by #{@event.author.distinct}")
      new_role.sort_above(@event.server.roles.find { |r| r.position == @event.server.bot.highest_role.position - 1 })
      add_role(new_role.id, hex)
    end
  end

  def parse(role)
    unless @valid_roles.map(&:downcase).include?(role.downcase)
      @event.respond "`#{role}` is not a valid role. Please select a role:\n\t#{@valid_roles}"
      @event.respond 'You can also get a HEX color by using `role hex <hex code>`'
      return
    end

    if @server_roles.keys.map(&:downcase).include?(role.downcase)
      role_to_add = @server_roles.keys.grep(/^#{role}$/i)[0]
      add_role(@server_roles[role_to_add], role_to_add)
      return
    end

    logger.info(format('[ROLE] Cannot find role on the server. Command: \'%<cmd>s\' was executed by: %<user>s in %<channel>s @ %<discord>s',
                       cmd: @event.text,
                       user: @event.author.distinct,
                       channel: @event.channel.name,
                       discord: @event.server.name))

    @event.respond 'While a valid role.. the server does not seem to have it. Ping a Mod.'
  end

  def remove_role(role)
    if @server_roles.keys.grep(/^#{role}$/i)[0].nil?
      logger.info(format('[ROLE] role %<role>s not found on %<user>s in %<channel>s @ %<discord>s',
                         role: role,
                         user: @event.author.distinct,
                         channel: @event.channel.name,
                         discord: @event.server.name))
      @event.respond "Role: `#{role}` not found on #{@event.author.mention}"
      return
    end

    role_to_remove = @server_roles.keys.grep(/^#{role}$/i)[0]
    begin
      @event.author.remove_role(@server_roles[role_to_remove])
    rescue Discordrb::Errors::NoPermission
      @event.respond 'The bot does not have permisson to add the role.'
      logger.warn(format('[ROLE] Bot does not have permissons to remove role %<role>s in: %<channel>s @ %<discord>s',
                         role: role_to_remove,
                         channel: @event.channel.name,
                         discord: @event.server.name))
      return
    end
    logger.info(format('[ROLE] Removed role %<role>s from %<user>s in %<channel>s @ %<discord>s',
                       role: role_to_remove,
                       user: @event.author.distinct,
                       channel: @event.channel.name,
                       discord: @event.server.name))
    @event.respond "Removed role: `#{role_to_remove}` to #{@event.author.mention}"
  end

  def help
    logger.info(format('[ROLE] Responding to a role help command in: %<channel>s @ %<discord>s by: %<user>s',
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))
    @event.respond "Please select a role:\n\t#{@valid_roles.join("\n\t")}"
    @event.respond 'You can also get a HEX color by using `role hex <hex code>`'
  end
end
