set :output, path + "/cron_log.log"

# Brazil
# every 5.minutes do
#   runner "ExpaApplicationSync.call", environment: 'production'
# end

# every 5.minutes do
#   runner "ExpaIcxSync.call", environment: 'production'
# end

# every 7.minutes do
#   runner "SyncPodioApplicationStatus.call", environment:'production'
# end

# Peru
every 5.minutes do
    runner "ExpaPeopleSync.call", environment: 'production'
end
