set :output, "log/cron_log.log"
env :PATH, ENV['PATH']

every :sunday, at: '12am' do
  rake "create_new_period"
end

every 1.day, at: '12am' do
  rake "reset_checked_tests"
end
