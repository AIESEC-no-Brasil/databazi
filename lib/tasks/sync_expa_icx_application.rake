namespace :expa_sync do
  task icx_applications: :environment do
    logger = Logger.new STDOUT
    # logger = Logger.new 'log/expa_sync.log'
    logger.info 'Start loop'
    ExpaIcxSync.call logger
  end
end
