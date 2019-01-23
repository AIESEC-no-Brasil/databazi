class RepositoryApplication
  def self.save_icx_from_expa(application)
    ep = application.exchange_participant
    application.exchange_participant = ExchangeParticipant.where(
      expa_id: application.exchange_participant.expa_id
    ).first_or_create!(
      application.exchange_participant.attributes
    )
    if ep.registerable.new_record?
      ep.registerable.save
      application.exchange_participant.update_attributes(
        registerable: ep.registerable
      )
    end
    Expa::Application
      .where(expa_id: application.expa_id)
      .first_or_initialize(application.attributes)
      .update_attributes(podio_last_sync: nil)
  end
end
