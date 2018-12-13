require "#{Rails.root}/lib/expa_api"

class ExpaApplicationSync
  def self.call(from, to, page)
    new.call(from, to, page)
  end

  def call(from, to, page)
    load_applications(from, to, page).each do |application|
      ep = ExchangeParticipant.find_by_expa_id(application.person.id)
      next unless ep

      ep.expa_applications.create(expa_id: application.id,
                                  status: application.status)
    end
  end

  private

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
