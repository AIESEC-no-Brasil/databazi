class SyncPodioApplicationStatus
  def self.call
    new.call
  end

  def call
    last_applications(last_updated).each do |application|
      ep = application.exchange_participant
      update_podio(application) if ep.most_actual_application(application).id == application.id
    end
  end

  private

  def last_updated
    SyncParam.first&.updated_at || 3.month.ago.round
  end

  def last_applications(from)
    Expa::Application.where(updated_at: from).order(updated_at: :asc)
  end

  def update_podio(application)
    RepositoryPodio.change_status(
      application.exchange_participant.podio_id,
      Expa::Application.statuses[application.status])
  end
end