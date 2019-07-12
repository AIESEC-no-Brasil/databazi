class PodioEnableSynchronization
  def self.call(logger=nil)
    new.call logger
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)
    logger.info "Updating Expa::Applications"

    expa_applications = fetch_expa_applications

    expa_applications.update_all(podio_last_sync: nil)

    logger.info "Updated #{expa_applications.count} Expa::Applications"
  end

  def fetch_expa_applications
    Expa::Application
      .joins(:exchange_participant)
      .where(exchange_participants: { exchange_type: :icx })
      .where('completed_at > ?', Time.now())
      .where(status: 100)
      .where.not(podio_last_sync: nil)
      .where(has_error: false)
      .order(completed_at: :desc)
      .limit(10)
  end
end
