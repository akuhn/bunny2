require 'sinatra'
require 'haml'
require 'json'

require './lib/bunnylol'


get '/' do
  @query = @params.fetch('q') { 'list' }
  command, arguments = @query.split(' ', 2)

  if Bunny::COMMANDS.has_key?(command)
    @query = arguments.to_s
  else
    command = 'default'
  end

  instance_exec &Bunny::COMMANDS[command]
end
