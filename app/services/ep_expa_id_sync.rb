require "#{Rails.root}/lib/expa_api"

class EpExpaIdSync
  def self.call(**args)
    new.call(args)
  end

  def call(**args)
    logger = args[:logger] || Logger.new(STDOUT)
    logger.info 'ep_expa_id_sync.call'
    exchange_participant = ExchangeParticipant.find_by(expa_id: nil)
    return unless exchange_participant

    begin
      id = EXPAAPI::Client
        .query(
          ExistsQuery,
          variables: { email: exchange_participant.email.downcase })&.data&.check_person_present&.id
      
      id ? successful_sync(exchange_participant) : failed_sync(exchange_participant)

      exchange_participant.update_attributes(expa_id: id || 0)
    rescue StandardError => e
      logger.error "Error when sync #{exchange_participant.email.downcase} error #{e.to_json}"
      logger.error "#{e.backtrace.inspect}"
    end
  end

  private

  def successful_sync(exchange_participant)
    logger.debug("Found EP in expa #{exchange_participant.email.downcase} with EXPA_ID: #{id}")
    logger.debug("Updated EP with EXPA_ID: #{id}")
  end

  def failed_sync(exchange_participant)
    logger.warn("Couldn't find EP in expa #{exchange_participant.email.downcase}, retrying sign up")
    status = ExpaSignUp.call({ exchange_participant_id: exchange_participant.id }.stringify_keys)
    exchange_participant.reload
    logger.debug("Retry status: #{status}")
    logger.debug("EP has now EXPA ID: #{exchange_participant.expa_id}")
  end
end
