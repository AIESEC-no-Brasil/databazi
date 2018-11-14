class GvParticipantsController < ApplicationController
  include ExchangeParticipantable
  before_action :campaign_sign_up

  expose :gv_participant
  expose :exchange_participantable, -> { gv_participant }
  expose :ep_fields, -> { gv_participant_fields }
  expose :campaign, lambda {
    Campaign.where(utm_source: params[:gv_participant][:utm_source],
                   utm_medium: params[:gv_participant][:utm_medium],
                   utm_campaign: params[:gv_participant][:utm_campaign],
                   utm_term: params[:gv_participant][:utm_term],
                   utm_content: params[:gv_participant][:utm_content])
            .first_or_create
  }

  private

  def campaign_sign_up
    params_filled &&
      gv_participant.exchange_participant.campaign = campaign
  end

  def params_filled
    params[:gv_participant][:utm_source] &&
      params[:gv_participant][:utm_medium] &&
      params[:gv_participant][:utm_campaign] &&
      params[:gv_participant][:utm_term] &&
      params[:gv_participant][:utm_content]
  end

  def gv_participant_params
    nested_params
      .require(:gv_participant)
      .permit(exchange_participant_attributes: %i[
                id fullname birthdate email cellphone local_committee_id
                university_id college_course_id password scholarity
                campaign_id cellphone_contactable
              ])
  end

  def nested_params
    ActionController::Parameters.new(
      gv_participant: {
        exchange_participant_attributes: exchange_participant_params
      }
    )
  end

  def exchange_participant_params
    params[:gv_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity, :campaign_id, :cellphone_contactable)
  end

  def gv_participant_fields
    {
      'email' => gv_participant.email, 'fullname' => gv_participant.fullname,
      'cellphone' => gv_participant.cellphone,
      'birthdate' => gv_participant.birthdate,
      'utm_source' => utm_source, 'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign, 'utm_term' => utm_term,
      'utm_content' => utm_content, 'podio_app' => podio_app_id,
      'scholarity' => scholarity_human_name,
      'local_committee' => gv_participant.exchange_participant&.local_committee&.podio_id,
      'university' => gv_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => gv_participant.exchange_participant&.college_course&.podio_item_id,
      'cellphone_contactable' => gv_participant.exchange_participant.cellphone_contactable
    }
  end

  def podio_app_id
    ENV['PODIO_APP_GV']
  end

  def scholarity_human_name
    ep_scholarity = gv_participant.exchange_participant.scholarity
    ExchangeParticipant.human_enum_name(:scholarity, ep_scholarity)
  end

  def utm_source
    gv_participant&.exchange_participant&.campaign&.utm_source
  end

  def utm_medium
    gv_participant&.exchange_participant&.campaign&.utm_medium
  end

  def utm_campaign
    gv_participant&.exchange_participant&.campaign&.utm_campaign
  end

  def utm_term
    gv_participant&.exchange_participant&.campaign&.utm_term
  end

  def utm_content
    gv_participant&.exchange_participant&.campaign&.utm_content
  end
end
