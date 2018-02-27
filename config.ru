$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'dotenv'
require 'slack-ruby-bot'
Dotenv.load

require 'compliment-bot'
require 'calendar-bot'
require 'web'

Thread.abort_on_exception = true

Thread.new do
  begin
    ComplimentBot::Bot.run
    CalendarBot::Bot.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run ComplimentBot::Web
