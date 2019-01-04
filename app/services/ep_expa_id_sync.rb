require "#{Rails.root}/lib/expa_api"

class EpExpaIdSync
  def self.call(**args)
    new.call(args)
  end

  def call(**args)
    @logger = args[:logger] || Logger.new(STDOUT)
    @logger.info 'ep_expa_id_sync.call'
    exchange_participant = ExchangeParticipant.find_by(expa_id: nil)
    return unless exchange_participant

    @email = exchange_participant.email.downcase

    begin
      id = EXPAAPI::Client
        .query(
          ExistsQuery,
          variables: { email: @email })&.data&.check_person_present&.id

      id ? successful_sync(exchange_participant, id) : failed_sync(exchange_participant)

      exchange_participant.update_attribute('expa_id', id || 0)
    rescue StandardError => e
      @logger.error "Error when sync #{@email} error #{e.to_json}"
      raise
    end
  end

  private

  def successful_sync(exchange_participant, id)
    @logger.debug("Found EP in expa #{@email} with EXPA_ID: #{id}")
    @logger.debug("Updated EP with EXPA_ID: #{id}")
  end

  def failed_sync(exchange_participant)
    @logger.warn("Couldn't find EP in expa #{@email}, retrying sign up")
    status = ExpaSignUp.call({ exchange_participant_id: exchange_participant.id }.stringify_keys)
    exchange_participant.reload
    @logger.debug("Retry status: #{status}")
    @logger.debug("EP has now EXPA ID: #{exchange_participant.expa_id}")
  end
end
