namespace :expa_sync do
  task exchange_participants: :environment do
    logger = Logger.new STDOUT
    # logger = Logger.new 'log/expa_sync.log'
    logger.info 'Start loop'
    loop do
      EpExpaIdSync.call logger: logger
      sleep(2)
    end
  end
end
