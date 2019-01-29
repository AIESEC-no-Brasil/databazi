class RepositoryApplication
  def self.save_icx_from_expa(application)
    normalize_host_lc(application)
    ep = application.exchange_participant
    application.exchange_participant = ExchangeParticipant.where(
      expa_id: application.exchange_participant.expa_id
    ).first_or_create!(
      application.exchange_participant.attributes
    )
    if ep.registerable.new_record?
      ep.registerable.save
      application.exchange_participant.update_attributes(
        registerable: ep.registerable
      )
    end
    application.home_mc = MemberCommittee.where(
      expa_id: application.home_mc.expa_id
    ).first_or_create(
      name: application.home_mc.name,
      expa_id: application.home_mc.expa_id
    )
    application = Expa::Application
      .where(expa_id: application.expa_id)
      .first_or_initialize(application.attributes)
    application
      .update_attributes(podio_last_sync: nil)
    application
  end

  private

  def self.normalize_host_lc(application)
    lc = LocalCommittee.where(expa_id: application.host_lc.expa_id).first
    raise "Host LC not in database #{application.host_lc.expa_id}" if lc.nil?
    application.host_lc = lc
  end
end
