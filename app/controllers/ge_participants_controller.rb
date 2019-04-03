class GeParticipantsController < ApplicationController
  include ExchangeParticipantable
  include GeParticipantFields
  before_action :campaign_sign_up

  expose :ge_participant
  expose :exchange_participantable, -> { ge_participant }
  expose :ep_fields, -> { ge_participant_fields }
  expose :campaign, lambda {
    Campaign.where(utm_source: params[:ge_participant][:utm_source],
                   utm_medium: params[:ge_participant][:utm_medium],
                   utm_campaign: params[:ge_participant][:utm_campaign],
                   utm_term: params[:ge_participant][:utm_term],
                   utm_content: params[:ge_participant][:utm_content])
            .first_or_create
  }

  private

  def campaign_sign_up
    params_filled &&
      ge_participant.exchange_participant.campaign = campaign
  end

  def params_filled
    params[:ge_participant][:utm_source] &&
      params[:ge_participant][:utm_medium] &&
      params[:ge_participant][:utm_campaign] &&
      params[:ge_participant][:utm_term] &&
      params[:ge_participant][:utm_content]
  end

  def ge_participant_params
    nested_params.require(:ge_participant).permit(
      :preferred_destination,
      :spanish_level,
      :when_can_travel,
      :curriculum,
      english_level_attributes: [:english_level],
      exchange_participant_attributes: %i[
        id fullname email birthdate cellphone local_committee_id
        university_id college_course_id password scholarity
        campaign_id cellphone_contactable other_university referral_type city exchange_reason
      ]
    )
  end

  def nested_params
    ActionController::Parameters.new(
      ge_participant: {
        preferred_destination: ge_params[:preferred_destination].to_i,
        when_can_travel: ge_params[:when_can_travel].to_i,
        spanish_level: ge_params[:spanish_level].to_i,
        curriculum: ge_params[:curriculum],
        exchange_participant_attributes: normalized_exchange_participant_params,
        english_level_attributes: normalized_english_level_params
      }
    )
  end

  def ge_params
    params[:ge_participant]
  end

  def english_level_params
    params[:ge_participant]
      .slice(:english_level)
  end

  def normalized_english_level_params
    params = english_level_params
    params[:english_level] = params[:english_level].to_i

    params
  end

  def normalized_exchange_participant_params
    params = exchange_participant_params
    params[:scholarity] = params[:scholarity].to_i
    params[:referral_type] = params[:referral_type].to_i
    params[:exchange_reason] = params[:exchange_reason].to_i

    params
  end

  def exchange_participant_params
    params[:ge_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity, :campaign_id, :cellphone_contactable,
             :other_university, :referral_type, :city, :exchange_reason)
  end

  def scholarity_human_name
    ep_scholarity = ge_participant.exchange_participant.scholarity
    ExchangeParticipant.human_enum_name(:scholarity, ep_scholarity)
  end

  def utm_source
    ge_participant&.exchange_participant&.campaign&.utm_source
  end

  def utm_medium
    ge_participant&.exchange_participant&.campaign&.utm_medium
  end

  def utm_campaign
    ge_participant&.exchange_participant&.campaign&.utm_campaign
  end

  def utm_term
    ge_participant&.exchange_participant&.campaign&.utm_term
  end

  def utm_content
    ge_participant&.exchange_participant&.campaign&.utm_content
  end
end
