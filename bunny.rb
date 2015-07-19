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

create_table 'log', query: 'TEXT'

before do
  @query = @params.fetch('q') { 'list' }
  sqlite 'INSERT INTO log (query) VALUES (?)', [@query]
end

get '/opensearch.xml' do
  haml :opensearch
end

# Define default commands ...

bunnylol %w(history hist h), help: 'show search history' do
  @history = sqlite %(
    SELECT created_at, query
    FROM log
    ORDER BY created_at
    DESC LIMIT 40
  )
  haml :history
end

bunnylol %w(default google gg g), help: 'search on google' do
  base = 'https://www.google.com/search?q='
  redirect base << CGI.escape(@query)
end

bunnylol %w(help list), help: 'show list of commands' do
  @help = Bunny::HELP.sort_by { |name, help| name }
  haml :help
end
