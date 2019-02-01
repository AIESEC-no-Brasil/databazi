class ExpaIcxSync
  def self.call(logger=nil)
    new.call logger
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)
    logger.info "Start sync"

    RepositoryExpaApi.load_icx_applications(from).each do |application|
      begin
        logger.info "waiting"
        RepositoryApplication.save_icx_from_expa(application)
        logger.info "Saved ICX Application into Databazi"
      rescue => exception
        Raven.capture_exception(exception)
        @logger.error exception.message
      end
    end

    RepositoryApplication.pending_podio_sync_icx_applications.each do |application|
      begin
        RepositoryPodio.save_icx_application(application)
        logger.info "Saved ICX Application into Podio"
      rescue => exception
        Raven.capture_exception(exception)
        @logger.error exception.message
      end
    end
    logger.info "Done sync"
    sleep(2)
    true
  end

  def from
    (Expa::Application.order(updated_at_expa: :desc).first&.updated_at_expa  || 7.days.ago) + 1
  end
end