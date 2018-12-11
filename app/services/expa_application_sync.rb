require "#{Rails.root}/lib/expa_api"

class ExpaApplicationSync
  def self.call(from, to, page)
    new.call(from, to, page)
  end

  def call(from, to, page)
    load_applications(from, to, page).each do |application|
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

  def load_applications(from, to, page)
    EXPAAPI::Client.query(
      LoadApplications,
      variables: {
        to: to,
        from: from,
        page: page
      }
    ).data.all_opportunity_application.data
  end
end
