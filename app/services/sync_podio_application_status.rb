class SyncPodioApplicationStatus
  def self.call
    new.call
  end

  def call
    last_applications(last_updated).each do |application|
      ep = application.exchange_participant
      update_podio(application) if ep.most_actual_application(application).id == application.id
      update_last_updated(application.updated_at)
    end
  end

  private

  def last_updated
    SyncParam.first&.podio_application_status_last_sync || 3.month.ago.round
  end

  def update_last_updated(updated)
    SyncParam.first_or_create.update_attributes(podio_application_status_last_sync: updated)
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