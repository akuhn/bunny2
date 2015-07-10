require 'sinatra/base'
require 'sqlite3'

module Sequel

  DB = SQLite3::Database.new('bunnylol.sqlite')

  def sqlite(query, values = nil)
    DB.execute(query, values)
  end

  DB.execute %{
    CREATE TABLE IF NOT EXISTS bookmarks(
      t DATETIME DEFAULT CURRENT_TIMESTAMP,
      url TEXT
    )
  }

end

module Sinatra
  helpers Sequel
end
