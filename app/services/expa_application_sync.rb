require "#{Rails.root}/lib/expa_api"

class ExpaApplicationSync
  def self.call
    new.call
  end

  def call
    load_applications.each do |application|
      ep = exchange_participant_by_expa_id(application.person.id)
      next unless ep

      ep.update_attributes(expa_id: application.person.id)
      Expa::Application.create(
        expa_id: application.id,
        status: application.status,
        exchange_participant_id: ep.id
      )
    end
  end

  private

  def exchange_participant_by_expa_id(expa_id)
    ExchangeParticipant.find_by(
      expa_id: expa_id
    )
  end

  def load_applications
    EXPAAPI::Client.query(
      LoadApplications
    ).data.all_opportunity_application.data
  end
end
