set :output, path + "/cron_log.log"

if ENV['COUNTRY'] == 'per'
  every 5.minutes do
    runner "ExpaPeopleSync.call", environment: 'production'
  end
end

if ENV['COUNTRY'] == 'bra'
  every 5.minutes do
    runner "ExpaApplicationSync.call", environment: 'production'
  end

  every 5.minutes do
    runner "ExpaIcxSync.call", environment: 'production'
  end

  every 7.minutes do
    runner "SyncPodioApplicationStatus.call", environment:'production'
  end
end
