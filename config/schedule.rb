every :sunday, at: '12am' do
  rake "create_new_period"
end

every 1.day, at: '10:30 am' do
  rake "reset_checked_tests"
end
