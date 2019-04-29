require "#{Rails.root}/lib/expa_api"
require "#{Rails.root}/app/repos/chat_logger"

class ExpaApplicationSync
  def self.call(logger=nil)
    new.call(logger)
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)
    from = (Expa::Application.order(updated_at_expa: :desc).first&.updated_at_expa  || 3.month.ago) + 1
    logger.info "Start sync"
    logger.debug"Sync from #{from}"
    applications = load_applications(from)
    logger.debug "Applications count #{applications.count}"
    applications = applications.sort { |a, b| Time.parse(a.updated_at) <=> Time.parse(b.updated_at) }
    applications.each do |application|
      begin
        ep = ExchangeParticipant.find_by_expa_id(application.person.id)

        unless ep.nil?
          ep.expa_applications.where(expa_id: application.id)
            .first_or_initialize
            .update_attributes(status: application.status,
                              expa_ep_id: application.person.id,
                              updated_at_expa: parsed_date(application.updated_at),
                              applied_at: parsed_date(application.created_at),
                              accepted_at: application.status != 'rejected' ? parsed_date(application.matched_or_rejected_at) : nil,
                              approved_at: parsed_date(application.date_approved),
                              break_approved_at: application.status == 'rejected' ? parsed_date(application.matched_or_rejected_at) : nil,
                              realized_at: parsed_date(application.date_realized),
                              completed_at: parsed_date(application.experience_end_date),
                              podio_last_sync: nil,
                              product: application.opportunity.programme.short_name_display.downcase.to_sym,
                              tnid: application.opportunity.id,
                              standards: application.standards)
          ep.update_attributes(status: exchange_participant_status_expa(application.person.status))
          log = "Sync application with EP #{ep&.fullname}"
        end

        if ep.nil?
          Expa::Application.where(expa_id: application.id)
            .first_or_initialize
            .update_attributes(status: application.status,
                              expa_ep_id: application.person.id,
                              updated_at_expa: parsed_date(application.updated_at),
                              applied_at: parsed_date(application.created_at),
                              accepted_at: application.status != 'rejected' ? parsed_date(application.matched_or_rejected_at) : nil,
                              approved_at: parsed_date(application.date_approved),
                              break_approved_at: application.status == 'rejected' ? parsed_date(application.matched_or_rejected_at) : nil,
                              realized_at: parsed_date(application.date_realized),
                              completed_at: parsed_date(application.experience_end_date),
                              podio_last_sync: nil,
                              product: application.opportunity.programme.short_name_display.downcase.to_sym,
                              tnid: application.opportunity.id,
                              standards: application.standards)

          log = 'Sync application without EP'
        end
        log += " last status #{application.status}"
        log += " application id #{application.id}"
        logger.info log
      rescue StandardError => error
        message = "Error when trying sync ogx applications: #{error.message}"
        logger.error message
        Repos::ChatLogger.notify_on_client_channel(message)
      end
    rescue StandardError => error
      message = "Error when trying sync ogx applications: #{error.message}"
      logger.error message
      Repos::ChatLogger.notify_on_client_channel(message)
      raise
    end
  end


  private

  def exchange_participant_status_expa(status)
    status == "other" ? :other_status : status
  end

  def parsed_date(date)
    Time.parse(date) if date
  end

  def load_applications(from)
    EXPAAPI::Client.query(
      LoadApplications,
      variables: {
        from: from
      }
    ).data.all_opportunity_application.data
  end
end
