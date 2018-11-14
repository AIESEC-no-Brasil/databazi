class GeParticipantsController < ApplicationController
  include ExchangeParticipantable
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
      :spanish_level,
      exchange_participant_attributes: %i[
        id fullname email birthdate cellphone local_committee_id
        university_id college_course_id password scholarity
        campaign_id cellphone_contactable
      ],
      english_level_attributes: [:english_level]
    )
  end

  def nested_params
    ActionController::Parameters.new(
      ge_participant: {
        spanish_level: params[:ge_participant][:spanish_level],
        exchange_participant_attributes: exchange_participant_params,
        english_level_attributes: english_level_params
      }
    )
  end

  def exchange_participant_params
    params[:ge_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity, :campaign_id, :cellphone_contactable)
  end

  def english_level_params
    params[:ge_participant]
      .slice(:english_level)
  end

  def ge_participant_fields
    {
      'email' => ge_participant.email, 'fullname' => ge_participant.fullname,
      'cellphone' => ge_participant.cellphone,
      'birthdate' => ge_participant.birthdate,
      'utm_source' => utm_source, 'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign, 'utm_term' => utm_term,
      'utm_content' => utm_content, 'podio_app' => podio_app_id,
      'scholarity' => scholarity_human_name,
      'local_committee' => ge_participant.exchange_participant&.local_committee&.podio_id,
      'spanish_level' => ge_participant.read_attribute_before_type_cast(:spanish_level),
      'english_level' => ge_participant&.english_level&.read_attribute_before_type_cast(:english_level),
      'university' => ge_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => ge_participant.exchange_participant&.college_course&.podio_item_id,
      'cellphone_contactable' => ge_participant.exchange_participant.cellphone_contactable
    }
  end

  def podio_app_id
    ENV['PODIO_APP_GE']
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
