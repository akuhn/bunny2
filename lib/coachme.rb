require 'json'

bunnylol %w(coachme cme), help: 'show tile plot of coachme checkins' do
  if @query == 'fetch'
    coachme_fetch
  else
    coachme_show
  end
end

def coachme_fname
  'data/coachme.json'
end

def coachme_show
  @habits = JSON.parse(File.read(coachme_fname))
  @date_range = (Date.today - 48)..Date.today

  haml :coachme
end

def coachme_fetch
  require 'net/http'
  require 'nokogiri'

  user_id, user_hash = ENV['COACHME'].split(':')
  url = "https://www.coach.me/api/v3/users/#{user_id}/stats?expanded=true"
  stats = JSON.parse(Net::HTTP.get(URI(url)));
  data = stats['plans'].map do |d|
    name, habit_id = d.values_at('name', 'habit_id')
    p url = "https://www.coach.me/users/#{user_hash}/#{habit_id}"
    doc = Nokogiri::HTML(Net::HTTP.get(URI(url)))
    calendar = doc.search('h3').map do |h3|
      [h3.text, h3.next_element.search('.cal-day.checked').map(&:text).map(&:to_i)]
    end
    checkins = []
    calendar.each do |month, days|
      next if month == 'Notes'
      month = Date.parse(month)
      days.each { |day| checkins << (month + day - 1).strftime }
    end
    [name, checkins]
  end.to_h
  File.rename(coachme_fname, coachme_fname + '.bak') if File.exist? coachme_fname
  File.open(coachme_fname, 'w') { |f| JSON.dump(data, f) }

  "Found #{data.values.flatten.count} checkins since #{data.values.flatten.min}"
end
