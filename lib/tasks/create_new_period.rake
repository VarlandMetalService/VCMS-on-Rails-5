# file: lib/tasks/create_new_period.rake

desc 'create a new period for this week'
task create_new_period: :environment do
  Period.create({
    period_start_date: Date.today,
    period_end_date: Date.tomorrow.end_of_week - 1,
    is_closed: false
  })
end