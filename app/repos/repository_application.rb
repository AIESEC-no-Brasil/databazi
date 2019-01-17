class RepositoryApplication
  def self.save_icx_from_expa(application)
    application.exchange_participant = ExchangeParticipant.where(
      expa_id: application.exchange_participant.expa_id
    ).first_or_create!(
      application.exchange_participant.attributes
    )
    Expa::Application
      .where(expa_id: application.expa_id)
      .first_or_create(application.attributes)
  end
end
