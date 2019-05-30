class RepositoryApplication
  def self.save_icx_from_expa(application)
    normalize_host_lc(application)
    normalize_home_lc(application)
    normalize_home_mc(application)
    normalize_ep(application)
    Expa::Application
      .where(expa_id: application.expa_id)
      .first_or_create!(application.attributes)
      .update!(
        podio_last_sync: nil,
        status: application.status,
        updated_at_expa: application.updated_at_expa,
        applied_at: application.applied_at,
        approved_at: application.approved_at,
        realized_at: application.realized_at,
        completed_at: application.completed_at,
        accepted_at: application.accepted_at,
        break_approved_at: application.break_approved_at,
        sdg_goal_index: application.sdg_goal_index,
        sdg_target_index: application.sdg_target_index,
        tnid: application.tnid,
        opportunity_name: application.opportunity_name,
        opportunity_date: application.opportunity_date,
        product: application.product,
        academic_backgrounds: application.academic_backgrounds,
        home_mc: application.home_mc,
        host_lc: application.host_lc,
        home_lc: application.home_lc,
        standards: application.standards,
        exchange_participant_id: application.exchange_participant.id
      )

      check_impact_brazil_referral(application)
  end

  def self.pending_podio_sync_icx_applications
    Expa::Application
      .where('exchange_participant_id is not null')
      .where.not(status: %i[approved_tn_manager approved_ep_manager]) #this statuses should be ignored in this context
      .joins(:exchange_participant)
      .where(exchange_participants: { exchange_type: :icx })
      .where(podio_last_sync: nil)
      .where(has_error: false)
      .order('updated_at_expa': :desc)
      .limit(10)
  end

  private

  def self.check_impact_brazil_referral(expa_application)
    Expa::Application.where(expa_id: expa_application.expa_id).update_all({:from_impact => true}) if impact_brazil_referral(expa_application)
  end

  def self.impact_brazil_referral(expa_application)
    ImpactBrazilReferral.find_by(ep_expa_id: expa_application.expa_ep_id,
                                 opportunity_expa_id: expa_application.tnid,
                                 application_expa_id: expa_application.expa_id)
  end

  def self.normalize_ep(application)
    most_recent_ep = application.exchange_participant

    application.exchange_participant = ExchangeParticipant.where(
      expa_id: most_recent_ep.expa_id
    ).first_or_create!(
      most_recent_ep.attributes
    )

    application.exchange_participant.update(
      fullname: most_recent_ep.fullname,
      email: most_recent_ep.email,
      cellphone: most_recent_ep.cellphone,
      cellphone_contactable: most_recent_ep.cellphone_contactable,
      exchange_type: most_recent_ep.exchange_type,
      academic_backgrounds: most_recent_ep.academic_backgrounds
    )

    if most_recent_ep.registerable.new_record?
      most_recent_ep.registerable.save
      application.exchange_participant.update_attributes(
        registerable: most_recent_ep.registerable
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
