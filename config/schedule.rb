# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, path + "/cron_log.log"

every 20.minutes do
  runner "ExpaApplicationSync.call", environment:'production'
end

# every 20.minutes do
#   runner "SyncPodioApplicationStatus.call", environment:'production'
# end

# Learn more: http://github.com/javan/whenever
