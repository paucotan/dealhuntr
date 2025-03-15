# config/schedule.rb
set :output, "log/cron.log"  # Log output to log/cron.log

# Run every Monday at 9:00 AM (adjust time as needed)
every :monday, at: '9:00am' do
  runner "AlbertHeijnScraper.new.scrape"
end
