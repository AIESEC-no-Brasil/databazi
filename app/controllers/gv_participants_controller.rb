class GvParticipantsController < ApplicationController
  include ExchangeParticipantable
  include GvParticipantFields
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
      params[:gv_participant][:utm_campaign]
  end

  def gv_participant_params
    nested_params
      .require(:gv_participant)
      .permit(
        :when_can_travel,
        exchange_participant_attributes: exchange_participant_permitted_attributes
    )
  end

  def exchange_participant_permitted_attributes
    %i[
      id fullname birthdate email cellphone local_committee_id
      university_id college_course_id password scholarity
      campaign_id cellphone_contactable other_university referral_type city department signup_source scholarity_stage exchange_reason university_name
    ]
  end

  def nested_params
    ActionController::Parameters.new(
      gv_participant: {
        when_can_travel: params[:gv_participant][:when_can_travel].to_i,
        exchange_participant_attributes: normalized_exchange_participant_params
      }
    )
  end

  def exchange_participant_params
    params[:gv_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity, :campaign_id, :cellphone_contactable,
             :other_university, :referral_type, :signup_source)
  end

  def normalized_exchange_participant_params
    params = exchange_participant_params
    params[:scholarity] = params[:scholarity].to_i
    params[:signup_source] = params[:signup_source].to_i
    params[:referral_type] = params[:referral_type].to_i
    params[:signup_source] = params[:signup_source].to_i

    params
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
