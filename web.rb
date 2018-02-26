require 'sinatra/base'

module ComplimentBot
  class Web < Sinatra::Base
    get '/' do
      'Reptar'
    end
  end
end
