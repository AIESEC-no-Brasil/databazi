class ExpaIcxSync
  def self.call(logger=nil)
    new.call logger
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)
    logger.info "Start sync"

    RepositoryExpaApi.load_icx_applications(from).each do |application|

      puts RepositoryApplication.save_icx_from_expa(application).to_json
      # RepositoryPodio.save_icx_application(application)
    end
    logger.info "Done sync"
    true
  end

  def from
    3.month.ago + 1
    # (Expa::Application.order(updated_at_expa: :desc).first&.updated_at_expa  || 3.month.ago) + 1
  end
end