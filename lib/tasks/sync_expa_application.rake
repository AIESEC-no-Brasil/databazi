namespace :expa_sync do
  task ogx_applications: :environment do
    logger = Logger.new STDOUT
    # logger = Logger.new 'log/expa_sync.log'
    logger.info 'Start loop'
    loop do
      ExpaApplicationSync.call logger
      sleep(2)
    end
  end
end
