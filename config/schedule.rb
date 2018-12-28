# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, path + "/cron_log.log"

every 1.hour  do
  runner "ExpaApplicationSyncScheduler.call", environment:'development'
end

every 20.minutes do
  runner "SyncPodioApplicationStatus.call", environment:'development'
end

# Learn more: http://github.com/javan/whenever
