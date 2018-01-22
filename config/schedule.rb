# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.day, at: '11:55 pm' do
  rake 'fund_report:exchange_rates'
end

every 1.day, at: '0:10 am' do
  rake 'fund_report:last_day_balance_report'
end

every 1.day, at: '0:13 am' do
  rake 'fund_report:fund_report'
end
