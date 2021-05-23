# frozen_string_literal: true

# Basic Ping class to see if bot is working.
class Quote
  include Logging
  def initialize(event)
    @event = event
    @json_file = File.read('data/quotes.json')
    @all_quotes = JSON.parse(@json_file)
    @server_quotes = @all_quotes[@event.server.id.to_s]
    @quote_html = ''
  end

  def random_quote
    update_html
    @event.respond @server_quotes.sample
  end

  def update_html
    @server_quotes.each do |quote|
      @quote_html += "#{quote}\n==================================================\n"
    end
    @quote_html = @quote_html.gsub(/</, '&lt;')
    @quote_html = @quote_html.gsub(/>/, '&gt;')

    @quote_html = "<head><meta charset=\"utf-8\"/></head><pre>#{@quote_html}</pre>"

    File.open("data/quotes/#{@event.server.id}", 'w') do |f|
      f.write(@quote_html)
    end
  end
end
