class GtParticipantsController < ApplicationController
  include ExchangeParticipantable
  include GtParticipantFields
  before_action :campaign_sign_up

  expose :gt_participant
  expose :exchange_participantable, -> { gt_participant }
  expose :ep_fields, -> { gt_participant_fields }
  expose :campaign, lambda {
    Campaign.where(utm_source: params[:gt_participant][:utm_source],
                   utm_medium: params[:gt_participant][:utm_medium],
                   utm_campaign: params[:gt_participant][:utm_campaign],
                   utm_term: params[:gt_participant][:utm_term],
                   utm_content: params[:gt_participant][:utm_content])
            .first_or_create
  }

  private

  def campaign_sign_up
    params_filled &&
      gt_participant.exchange_participant.campaign = campaign
  end

  def params_filled
    params[:gt_participant][:utm_source] &&
      params[:gt_participant][:utm_campaign]
  end

  def gt_participant_params
    nested_params.require(:gt_participant).permit(
      :curriculum,
      :preferred_destination,
      english_level_attributes: [:english_level],
      exchange_participant_attributes:
        exchange_participant_permitted_attributes,
      experience_attributes: experience_permitted_attributes
    )
  end

  def exchange_participant_permitted_attributes
    %i[
      id fullname email birthdate cellphone local_committee_id
      university_id college_course_id password scholarity
      campaign_id cellphone_contactable other_university referral_type
    ]
  end

  def experience_permitted_attributes
    %i[
      id language marketing information_technology management
    ]
  end

  def nested_params
    ActionController::Parameters.new(
      gt_participant: {
        preferred_destination: gt_params[:preferred_destination].to_i,
        scholarity: gt_params[:scholarity],
        curriculum: gt_params[:curriculum],
        english_level_attributes: normalized_english_level_params,
        exchange_participant_attributes: normalized_exchange_participant_params,
        experience_attributes: experience_params
      }
    )
  end

  def gt_params
    params[:gt_participant]
  end

  def english_level_params
    params[:gt_participant]
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

    params
  end

  def exchange_participant_params
    params[:gt_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity, :campaign_id, :cellphone_contactable,
             :other_university, :referral_type)
  end

  def experience_params
    params[:gt_participant][:experience]
      .slice(:id, :language, :marketing, :information_technology, :management) if params[:gt_participant][:experience]
  end

  def scholarity_human_name
    ep_scholarity = gt_participant.exchange_participant.scholarity
    ExchangeParticipant.human_enum_name(:scholarity, ep_scholarity)
  end

  def utm_source
    gt_participant&.exchange_participant&.campaign&.utm_source
  end

  def utm_medium
    gt_participant&.exchange_participant&.campaign&.utm_medium
  end

  def utm_campaign
    gt_participant&.exchange_participant&.campaign&.utm_campaign
  end

  def utm_term
    gt_participant&.exchange_participant&.campaign&.utm_term
  end

  def utm_content
    gt_participant&.exchange_participant&.campaign&.utm_content
  end
end
