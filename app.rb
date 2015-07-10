require 'sinatra'
require 'haml'
require 'json'

# Edit bunnylol.rb to add more commands!

module Bunnylol

  COMMANDS = {}
  HELP = {}

  def bunnylol(names, options = {}, &block)
    for name in names.map(&:to_s)
      HELP[name] = options[:help]
      COMMANDS[name] = block
    end
  end

end

register Bunnylol

bunnylol %w(default google gg g), help: 'search on google' do
  base = 'https://www.google.com/search?q='
  redirect base << CGI.escape(@query)
end

bunnylol %w(help list h l), help: 'show list of commands' do
  @help = Bunnylol::HELP.sort_by { |name, help| name }
  haml :help
end

require './bunnylol' # include user defined commands
require './database'

get '/' do
  words = @params.fetch('q') { 'list' }.split

  if Bunnylol::COMMANDS.key? words.first
    @query = words.drop(1).join(' ')
    instance_exec &Bunnylol::COMMANDS[words.first]
  else
    @query = words.join(' ')
    instance_exec &Bunnylol::COMMANDS['default']
  end
end

get '/opensearch.xml' do
  haml :opensearch
end
