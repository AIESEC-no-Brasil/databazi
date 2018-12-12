require "#{Rails.root}/lib/expa_api"

class ExpaApplicationSyncScheduler
  def self.call
    new.call
  end

  def call
    updated_at = Expa::Application.maximum('updated_at_expa')
    updated_at = Date.new(2018, 1, 1) if updated_at.nil?
    to = Time.now.change(sec: 0)
    total = EXPAAPI::Client.query(
      CountApplications,
      variables: {
        from: updated_at,
        to: to
      }
    ).data.all_opportunity_application.paging.total_pages
    page = 1
    loop do
      ExpaApplicationSyncWorker.perform_async(
        from: updated_at,
        to: to,
        page: page
      )
      page += 1
      break if page > total
    end
  end
end
