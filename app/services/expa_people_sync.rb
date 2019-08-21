class ExpaPeopleSync
  def self.call(logger=nil)
    new.call logger
  end

  def call(logger=nil)
    logger = logger || Logger.new(STDOUT)

    load_expa_people(from) { |person| perform_on_exchange_participant(person) }
  end

  private

  def perform_on_exchange_participant(person)
    exchange_participant = ExchangeParticipant.find_by(expa_id: person.id)

    unless exchange_participant || person.status == 'deleted'
      ExchangeParticipant.new(expa_id: person.id, updated_at_expa: person.updated_at, origin: :expa, status: person.status).save(validate: false)
    end

    if exchange_participant && exchange_participant.databazi?
      person_status = expa_person_status(person&.status)
      if status_modified?(exchange_participant&.status, person_status)
        exchange_participant.update_attributes(status: person_status.to_sym)
        begin
          update_rd_station(exchange_participant)
        rescue => e
          Raven.capture_message "Error updating RDStation",
          extra: {
            exchange_participant_id: exchange_participant.id,
            exception: e
          }
        end
      end
    end

    exchange_participant.update_attributes(updated_at_expa: person.updated_at) if exchange_participant

    sleep 5
  end

  def load_expa_people(from, page = 1, &callback)
    res = query_all_people(from)

    total_pages = res&.data&.all_people&.paging&.total_pages

    people = res&.data&.all_people&.data

    people.each do |person|
      begin
        callback.call(person)
      rescue => exception
        Raven.extra_context exchange_participant_expa_id: person.id
        Raven.capture_exception(exception)
        logger = logger || Logger.new(STDOUT)
        logger.error exception.message
        logger.error(exception.backtrace.map { |s| "\n#{s}" })
        break
      end

    end if people

    people = nil

    return load_expa_people(
      from,
      page + 1,
      &callback
    ) unless res.nil? || page + 1 > total_pages
  end

  def from
    (ExchangeParticipant
      .where.not(updated_at_expa: nil)
      .order(updated_at_expa: :desc)
      .first&.updated_at_expa  || 7.days.ago) + 1
  end

  def expa_person_status(status)
    status == 'other' ? :other_status : status
  end

  def status_modified?(status, expa_status)
    status != expa_status
  end

  def query_all_people(from)
    EXPAAPI::Client.query(
        ALLPEOPLE,
        variables: {
          from: from
        }
      )
  end

  def update_rd_station(exchange_participant)
    rdstation_integration = RdstationIntegration.new
    uuid = exchange_participant.rdstation_uuid

    unless uuid
      contact = rdstation_integration.fetch_contact_by_email(exchange_participant.try(:email))
      uuid = contact['uuid'] if contact
      exchange_participant.update_attribute(:rdstation_uuid, uuid) if uuid
    end

    rdstation_integration.update_lead_by_uuid(uuid, { cf_status: exchange_participant.status }) if uuid
  end

  def rdstation_authentication_token
    rdstation_authentication = RDStation::Authentication.new(ENV['RDSTATION_CLIENT_ID'], ENV['RDSTATION_CLIENT_SECRET'])
    rdstation_authentication.auth_url(ENV['RDSTATION_REDIRECT_URL'])

    rdstation_authentication.update_access_token(ENV['RDSTATION_REFRESH_TOKEN'])['access_token']
  end

end

ALLPEOPLE = EXPAAPI::Client.parse <<~'GRAPHQL'
  query ($from: DateTime) {
    allPeople(per_page: 500, sort: "+updated_at",
              filters: {
                home_committee: 1553,
                last_interaction: { from: $from }
              }
    ) {
        paging {
          total_pages
        }
        data {
          id
          status
          updated_at
      }
    }
  }
GRAPHQL

