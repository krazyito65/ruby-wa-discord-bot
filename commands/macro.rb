# frozen_string_literal: true

require 'json'

# Will display current server macros, and add/edit/delete them.
class Macro
  include Logging
  def initialize(event, action = '', macro_name = '', macro_text = '')
    @event = event
    @action = action
    @macro_name = macro_name
    @macro_text = macro_text
    @json_file = File.read('data/macros.json')
    @all_macros = JSON.parse(@json_file)
    @server_macros = @all_macros[@event.server.id.to_s]
    @macro_html = ''
  end

  def help
    logger.info(format('[MACRO] Responding to a macro command in: %<channel>s @ %<discord>s by: %<user>s',
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))
    @event.respond "You can find the macros here: http://bot.weakauras.wtf/#{@event.server.id}"
  end

  def update_html
    @server_macros.each do |macro_name, macro_text|
      @macro_html += "#{@event.bot.prefix}#{macro_name}: #{macro_text}\n==================================================\n"
    end
    @macro_html = @macro_html.gsub(/</, '&lt;')
    @macro_html = @macro_html.gsub(/>/, '&gt;')

    @macro_html = "<head><meta charset=\"utf-8\"/></head><pre>#{@macro_html}</pre>"

    File.open("data/#{@event.server.id}", 'w') do |f|
      f.write(@macro_html)
    end
  end

  def parse
    logger.info(format('[MACRO] Parsing macro command: \'%<cmd>s\' in: %<channel>s @ %<discord>s by: %<user>s',
                       cmd: @event.text,
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))

    # check if the user has manage message priv
    unless @event.author.can_view_server_insights?
      @event.respond 'You do not have privileges to edit macros.'
      return ''
    end

    case @action
    when 'add'
      add(@macro_name, @macro_text)
    when /(remove)|(delete)/
      remove(@macro_name, @macro_text)
    when 'edit'
      edit(@macro_name, @macro_text)
    else
      @event.respond "Invalid action: #{@action}"
      @event.respond 'Usage: !macro `[add/remove|delete/edit macro_name macro_text]`'
      logger.info(format('[MACRO] Invalid macro command: \'%<cmd>s\' in: %<channel>s @ %<discord>s by: %<user>s',
                         cmd: @event.text,
                         channel: @event.channel.name,
                         discord: @event.server.name,
                         user: @event.author.distinct))
    end
  end

  def add(name, text)
    logger.info(format('[MACRO] Running ADD command:\'%<cmd>s \' in: %<channel>s @ %<discord>s by: %<user>s',
                       cmd: @event.text,
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))

    unless @server_macros[name].nil?
      @event.respond "Macro `#{name}` already exists. Please use the `edit` command."
      return ''
    end

    @all_macros[@event.server.id.to_s][name] = text
    write_macro_to_file
    @event.respond "Macro `#{name}` has been added successfully!"
  end

  def remove(name, _text)
    logger.info(format('[MACRO] Running REMOVE command:\'%<cmd>s \' in: %<channel>s @ %<discord>s by: %<user>s',
                       cmd: @event.text,
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))

    if @server_macros[name].nil?
      @event.respond "Macro `#{name}` does not exist. Please check your spelling/case sensitivity."
      return ''
    end

    @all_macros[@event.server.id.to_s].delete(name)
    write_macro_to_file
    @event.respond "Macro `#{name}` has been removed successfully!"
  end

  def edit(name, text)
    logger.info(format('[MACRO] Running EDIT command:\'%<cmd>s \' in: %<channel>s @ %<discord>s by: %<user>s',
                       cmd: @event.text,
                       channel: @event.channel.name,
                       discord: @event.server.name,
                       user: @event.author.distinct))

    if @server_macros[name].nil?
      @event.respond "Macro `#{name}` does not exist. Please check your spelling/case sensitivity."
      return ''
    end

    @all_macros[@event.server.id.to_s][name] = text
    write_macro_to_file
    @event.respond "Macro `#{name}` has been edited successfully!"
  end

  def write_macro_to_file
    File.open('data/macros.json', 'w') do |f|
      f.write(JSON.pretty_generate(@all_macros))
    end
    update_html
  end
end
