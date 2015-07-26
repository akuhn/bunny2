# Smart commands for your browser

create_table 'bookmarks', url: 'TEXT'

bunnylol %w(bookmark book b), help: 'bookmark' do
  sqlite 'INSERT INTO bookmarks (url) VALUES (?)', [@query] unless @query.empty?
  @bookmarks = sqlite %(
    SELECT created_at, url
    FROM bookmarks
    ORDER BY created_at
    DESC LIMIT 40
  )

  haml :bookmarks
end
