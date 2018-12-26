namespace :podio_sync do
  task ep_podio_id: :environment do
    logger = Logger.new STDOUT
    logger.level = Logger::WARN
    # logger = Logger.new 'log/expa_sync.log'
    logger.info 'Start loop'
    loop do
      EpPodioIdSync.call logger: logger
      sleep(100)
    end
  end
end
