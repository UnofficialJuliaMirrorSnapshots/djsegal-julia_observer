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

set :output, "~rails/julia_observer/log/cron.log"

every :day, at: %w[ 2am 2pm 8am 8pm ] do
  command "echo 'boot job triggered.'"
  rake "job:boot"
end

every :day, at: %w[ 2:30am 2:30pm 8:30am 8:30pm ] do
  command "echo 'download job triggered.'"
  rake "job:download"
end

every :day, at: %w[ 4am 4pm 10am 10pm ] do
  command "echo 'expand job triggered.'"
  rake "job:expand"
end

every :day, at: %w[ 5am 5pm 11am 11pm ] do
  command "echo 'update job triggered.'"
  rake "job:update"
end

every :day, at: '12:30am' do
  command "echo 'log job triggered.'"
  rake "job:log"
end

every :day, at: '12:30pm' do
  command "echo 'refresh job triggered.'"
  rake "sitemap:refresh"
end

every :day, at: '6:30am' do
  command "echo 'scour job triggered.'"
  rake "job:scour"
end

every :day, at: '6:30pm' do
  command "echo 'clean job triggered.'"
  rake "job:clean"
end
