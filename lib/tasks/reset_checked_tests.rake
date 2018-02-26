desc 'clear all checked_by values'
task reset_checked_tests: :environment do
  SaltSprayTest.active.each do |t|
    t.checked_by = nil
    t.save
  end
end