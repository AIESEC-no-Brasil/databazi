require "#{Rails.root}/lib/expa_api"

class EpExpaIdSync
  def self.call(**args)
    new.call(args)
  end

  def call(**args)
    logger = args[:logger] || Logger.new(STDOUT)
    logger.info 'ep_expa_id_sync.call'
    ep = ExchangeParticipant.find_by(expa_id: nil)
    return if ep.nil?

    id = EXPAAPI::Client
      .query(
        ExistsQuery,
        variables: { email: ep.email.downcase })&.data&.check_person_present&.id
    logger.debug("Found ep in expa #{ep.email.downcase}") unless id.nil?
    logger.warn("Couldn't find ep in expa #{ep.email.downcase}") if id.nil?
    id ||= 0
    # ep.expa_id = id
    # ep.save(validate: false)
    ep.update_attributes(expa_id: id)
  end

  private

end
