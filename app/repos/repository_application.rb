class RepositoryApplication
  def self.save_icx_from_expa(application)
    normalize_host_lc(application)
    normalize_home_lc(application)
    normalize_home_mc(application)
    normalize_ep(application)
    application = Expa::Application
                  .where(expa_id: application.expa_id)
                  .first_or_initialize(application.attributes)
    application
      .update_attributes(podio_last_sync: nil)
    application
  end

  def self.pending_podio_sync_icx_applications
    Expa::Application
      .where('exchange_participant_id is not null')
      .where(podio_last_sync: nil)
      .order('updated_at_expa': :desc)
      .limit 10
  end

  private

  def self.normalize_ep(application)
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
  end

  def self.normalize_home_mc(application)
    application.home_mc = MemberCommittee.where(
      expa_id: application.home_mc.expa_id
    ).first_or_create!(
      name: application.home_mc.name,
      expa_id: application.home_mc.expa_id
    )
    application.home_mc.reload
  end

  def self.normalize_host_lc(application)
    lc = LocalCommittee.where(expa_id: application.host_lc.expa_id).first
    raise "Host LC not in database #{application.host_lc.expa_id}" if lc.nil?
    application.host_lc = lc
    application.host_lc.reload
  end

  def self.normalize_home_lc(application)
    lc = LocalCommittee
         .where(expa_id: application.home_lc.expa_id)
         .first_or_create!(name: application.home_lc.name)
    application.home_lc = lc
    application.home_lc.reload
  end
end
