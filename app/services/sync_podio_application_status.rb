class SyncPodioApplicationStatus
  def self.call(**args)
    new.call(args)
  end

  def call(**args)
    configure_logger(args)
    @logger.info '>>> #call'

    applications = last_applications

    applications.each do |application|
      begin
        @logger.debug ''
        ep = application.exchange_participant
        update_podio(application) if ep.most_actual_application(application).id == application.id
        application.update_attributes(podio_last_sync: Time.now)
      rescue => exception
        Raven.capture_exception(exception)
        @logger.error exception.message
        # Ignore errors
      end
    end

    applications.sort_by { |application| application.approved_at }.each do |application|
      begin
        send_application_to_podio(application) if application.approved?
      rescue => exception
        Raven.capture_exception(exception)
        @logger.error exception.message
        # Ignore errors
      end
    end

    @logger.info '<<< #call'
  end

  private

  def send_application_to_podio(application)
    return if application.podio_sent

    exchange_participant = application.exchange_participant
    approved_sync_count = exchange_participant.approved_sync_count

    unless approved_sync_count > 5
      RepositoryPodio.send_application(exchange_participant.podio_id, application, approved_sync_count)
    end
  end

  def last_applications
    Expa::Application
      .where('exchange_participant_id is not null')
      .where(podio_last_sync: nil)
      .joins(:exchange_participant)
      .where('exchange_participants.podio_id is not null')
      .order('updated_at_expa': :desc)
      .limit 10
  end

  def update_podio(application)
    fn = application.exchange_participant.fullname
    @logger.info "Updating podio status #{fn} with #{application.status}"
    @logger_success.info "Updating podio status #{fn} with #{application.status}"
    RepositoryPodio.change_status(
      application.exchange_participant.podio_id, application)
  end

  def configure_logger(args)
    default_logger = Logger.new(STDOUT)
    default_logger.level = Logger::INFO
    @logger = args[:logger] || default_logger
    @logger_success = Logger.new('log/podio_application_status_sync.log', 'daily')
  end
end
