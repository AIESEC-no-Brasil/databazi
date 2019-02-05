# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, path + "/cron_log.log"

every '* * * * *' do
  runner "ExpaApplicationSync.call", environment: 'production'
end

# workaround provided so the service is called every 30 seconds

every '* * * * *' do
  runner "DelayedCall.call({ delay: 30, job: 'ExpaApplicationSync' })", environment: 'production'
end

every '* * * * *' do
  runner "ExpaIcxSync.call", environment: 'production'
end

# workaround provided so the service is called every 30 seconds

every '* * * * *' do
  runner "DelayedCall.call({ delay: 30, job: 'ExpaIcxSync' })", environment: 'production'
end

every 1.minute do
  runner "SyncPodioApplicationStatus.call", environment:'production'
end

# Learn more: http://github.com/javan/whenever
