namespace :podio_sync do
  task ep_podio_id: :environment do
    logger = Logger.new STDOUT
    # logger.level = Logger::WARN

    Podio.setup(
      api_key: ENV['PODIO_API_KEY'],
      api_secret: ENV['PODIO_API_SECRET']
    )
    Podio.client.authenticate_with_credentials(
      ENV['PODIO_USERNAME'],
      ENV['PODIO_PASSWORD']
    )
    # logger = Logger.new 'log/expa_sync.log'
    logger.info 'Start loop'
    loop do
      logger.info 'Loop'
      EpPodioIdSync.call logger: logger
      logger.info 'Wait... we cant work that much'
      sleep(2)
    end
  end
end
