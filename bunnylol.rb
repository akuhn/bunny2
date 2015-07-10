# Smart commands for your browser

bunnylol %w(bookmark book b), help: 'bookmark' do
  sqlite 'INSERT INTO bookmarks (url) VALUES (?)', [@query] unless @query.empty?
  @bookmarks = sqlite 'SELECT * FROM bookmarks ORDER BY t DESC LIMIT 40'

  haml :bookmarks
end
