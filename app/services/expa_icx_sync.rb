class ExpaIcxSync
  def self.call(logger=nil)
    new.call logger
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)
    logger.info "Start sync"

    RepositoryExpaApi.load_icx_applications(from).each do |application|
      logger.info "waiting"
      sleep(2)
      save_application = RepositoryApplication.save_icx_from_expa(application)
      logger.info "Saved ICX Application into Databazi"
      RepositoryPodio.save_icx_application(save_application)
      logger.info "Saved ICX Application into Podio"
    end
    logger.info "Done sync"
    true
  end

  def from
    (Expa::Application.order(updated_at_expa: :desc).first&.updated_at_expa  || 7.days.ago) + 1
  end
end