class ExpaIcxSync
  def self.call(logger=nil)
    new.call logger
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)
    logger.info "Start sync"

    logger.info "Loading ICX Applications from expa"
    RepositoryExpaApi.load_icx_applications(from).each do |application|
      begin
        logger.info "Saving into databazi"
        RepositoryApplication.save_icx_from_expa(application)
      rescue => exception
        Raven.extra_context application_expa_id: application&.expa_id
        Raven.capture_exception(exception)
        logger.error exception.message
        logger.error(exception.backtrace.map { |s| "\n#{s}" })
        break
      end
    end

    RepositoryApplication.pending_podio_sync_icx_applications.each do |application|
      begin
        logger.info "Saving into Podio #{application.product} - #{application.updated_at_expa}"
        RepositoryPodio.save_icx_application(application)
      rescue => exception
        Raven.capture_exception(exception)
        logger.error exception.message
        application.update_attribute(:has_error, true)
      end
    end
    logger.info "Done sync"
    sleep(2)
    true
  end

  def from
    (Expa::Application
      .joins(:exchange_participant)
      .where(exchange_participants: { exchange_type: :icx })
      .order(updated_at_expa: :desc)
      .first&.updated_at_expa  || 7.days.ago) + 1
  end
end
