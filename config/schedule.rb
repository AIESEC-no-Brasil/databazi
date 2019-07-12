set :output, path + "/cron_log.log"

every 5.minutes do
  runner "ExpaApplicationSync.call", environment: 'production'
end

every 5.minutes do
  runner "PodioEnableSynchronization.call", environment: 'production'
end

every 5.minutes do
  runner "ExpaIcxSync.call", environment: 'production'
end

every 7.minutes do
  runner "SyncPodioApplicationStatus.call", environment:'production'
end
