require 'sinatra/base'
require 'sqlite3'

module Sequel

  DB = SQLite3::Database.new('bunnylol.sqlite')

  def sqlite(query, values = nil)
    Sequel::DB.execute(query, values)
  end

end

module Bunny

  COMMANDS = {}
  HELP = {}

  def bunnylol(names, options = {}, &block)
    for name in names.map(&:to_s)
      HELP[name] = options[:help]
      COMMANDS[name] = block
    end
  end

  def create_table(name, columns)
    columns[:created_at] = 'DATETIME DEFAULT CURRENT_TIMESTAMP'
    body = columns.map { |name, type| "`#{name}` #{type}" }.join(', ')
    Sequel::DB.execute("CREATE TABLE IF NOT EXISTS `#{name}` (#{body})")
  end

end

register Bunny

helpers Sequel

# Define default commands ...

bunnylol %w(default google gg g), help: 'search on google' do
  base = 'https://www.google.com/search?q='
  redirect base << CGI.escape(@query)
end

bunnylol %w(help list h l), help: 'show list of commands' do
  @help = Bunny::HELP.sort_by { |name, help| name }
  haml :help
end

get '/opensearch.xml' do
  haml :opensearch
end
