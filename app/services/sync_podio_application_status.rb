class SyncPodioApplicationStatus
  def self.call(**args)
    new.call(args)
  end

  def call(**args)
    configure_logger(args)
    @logger.info '>>> #call'
    last_applications(last_updated).each do |application|
      @logger.debug ''
      ep = application.exchange_participant
      update_podio(application) if ep.most_actual_application(application).id == application.id
      update_last_updated(application.updated_at)
    end
    @logger.info '<<< #call'
  end

  private

  def last_updated
    l = SyncParam.first&.podio_application_status_last_sync || 6.month.ago.round
    @logger.info "Last sync was #{l}"
    l
  end

  def update_last_updated(updated)
    @logger.info "Update last sync to #{updated}"
    SyncParam.first_or_create.update_attributes(podio_application_status_last_sync: updated)
  end

  def last_applications(from)
    Expa::Application
      .where('expa_applications.updated_at >= ?', from)
      .where('exchange_participant_id is not null')
      .joins(:exchange_participant)
      .where('exchange_participants.podio_id is not null')
      .order('updated_at': :asc)
      .limit 10
  end

  def update_podio(application)
    fn = application.exchange_participant.fullname
    @logger.info "Updating podio status #{fn} with #{application.status}"
    @logger_success.info "Updating podio status #{fn} with #{application.status}"
    RepositoryPodio.change_status(
      application.exchange_participant.podio_id, application.status)
  end

  def configure_logger(args)
    default_logger = Logger.new(STDOUT)
    default_logger.level = Logger::INFO
    @logger = args[:logger] || default_logger
    @logger_success = Logger.new('log/podio_application_status_sync.log', 'daily')
  end
end
