require 'sinatra'
require 'haml'
require 'json'

# Edit bunnylol.rb to add more commands!

require './bunny'
require './bunnylol'

get '/' do

  @query = @params.fetch('q') { 'list' }

  command = @query.split.first

  if Bunny::COMMANDS.has_key? command
    @query = @query.split.drop(1).join(' ')
  else
    command = 'default'
  end

  instance_exec &Bunny::COMMANDS[command]

end
