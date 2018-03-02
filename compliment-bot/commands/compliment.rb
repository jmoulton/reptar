require 'constants'

module ComplimentBot
  module Commands
    class Compliment < SlackRubyBot::Commands::Base
      help do
        title 'Reptar'
        desc 'This :badass: Dinosaur bot will give you information on your calendar events and room availabilty :party-dinosaur:'
      end

      command 'compliment me' do |client, data, _match|
        client.say(channel: data.channel, text: Constants::COMPLIMENTS.sample(1))
      end

      command('hey', 'sup', 'yo') do |client, data, _match|
        client.say(channel: data.channel, text: Constants::GREETINGS.sample(1))
      end

      command('you da man') do |client, data, _match|
        client.say(channel: data.channel, text: 'No, YOU da man!')
      end
    end
  end
end
