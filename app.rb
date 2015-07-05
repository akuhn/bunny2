require 'sinatra'
require 'haml'

# Edit bunnylol.rb to add more commands!

module Bunnylol

  @@commands = {}
  @@help = {}
  @@query = nil

  def bunnylol(names, options = {}, &block)
    for name in names.map(&:to_s)
      @@help[name] = options[:help]
      @@commands[name] = block
    end
  end

  def commands
    @@commands
  end

  def help
    @@help
  end

  def query= query
    @@query = query.join(' ')
  end

  def query
    @@query
  end

end

helpers Bunnylol
register Bunnylol

bunnylol %w(default google gg g), help: 'search on google' do
  base = 'https://www.google.com/search?q='
  redirect base << CGI.escape(query)
end

bunnylol %w(help list h l), help: 'show list of commands' do
  @help = help.sort_by { |name, help| name }
  haml :help
end

require './bunnylol' # include user defined commands

get '/' do
  words = @params.fetch('q') { 'list' }.split

  if commands.key? words.first
    self.query = words.drop(1)
    instance_exec &commands[words.first]
  else
    self.query = words
    instance_exec &commands['default']
  end
end
