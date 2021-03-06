# Smart commands for your browser
require 'tzinfo'

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

bunnylol %w{timezones tz}, help: 'view timezone table' do
  now = Time.now.utc
  timezone_names = %w{
    America/Los_Angeles
    America/New_York
    Europe/Berlin
    Asia/Shanghai
  }

  @timezones = timezone_names.map { |name| TZInfo::Timezone.get(name) }
  @hours = 72.times.map { |n| now + 3600 * n }
  @today = @timezones.first.utc_to_local(now).strftime('%a, %b %d')
  @tomorrow = @timezones.first.utc_to_local(now + 24 * 3600).strftime('%a, %b %d')

  haml :timezones
end

bunnylol %w(facebook fb), help: 'go to facebook profile' do
  base = 'https://www.facebook.com/profile.php?id='
  redirect base << CGI.escape(@query)
end

bunnylol %w(twitter tw t), help: 'open twitter' do
  base = 'https://twitter.com'
  redirect base unless @query
  redirect base << '/search?q=' << CGI.escape(@query)
end

bunnylol %w{bing bb}, help: 'search with bing' do
  base = 'https://bing.com'
  redirect base unless @query
  redirect base << '/search?q=' << CGI.escape(@query)
end

bunnylol %w{kitty k}, help: 'view cryptokitty' do
  base = 'https://cryptokitties.co'
  redirect base unless @query
  kitten_number = @query.start_with?('0000') ? @query.to_i(16).to_s : @query
  redirect base << '/kitty/' << CGI.escape(kitten_number)
end

bunnylol %w{dx docs}, help: 'search google documents' do
  base = 'https://docs.google.com'
  redirect base unless @query
  redirect base << '?q=' << CGI.escape(@query)
end

bunnylol %w{unescape un}, help: 'unescape a url' do
  unescaped_query = @query
  3.times { unescaped_query = CGI.unescape(unescaped_query) }
  redirect unescaped_query
end

bunnylol %w{coin c}, help: 'flip a coin' do
  @content = %w{head tail}.sample
  haml :h1
end

bunnylol %w{d6}, help: 'roll a dice' do
  @content = "#{(1..6).entries.sample} of 6"
  haml :h1
end
