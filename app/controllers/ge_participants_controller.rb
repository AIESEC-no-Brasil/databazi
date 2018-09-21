class GeParticipantsController < ApplicationController
  include ExchangeParticipantable
  before_action :campaign_sign_up

  expose :ge_participant
  expose :exchange_participantable, -> { ge_participant }
  expose :ep_fields, -> { ge_participant_fields }
  expose :campaign, lambda {
    Campaign.where(source: params[:ge_participant][:source],
                   medium: params[:ge_participant][:medium],
                   campaign: params[:ge_participant][:campaign]).first_or_create
  }

  private

  def campaign_sign_up
    params[:ge_participant][:source] && params[:ge_participant][:medium] &&
      params[:ge_participant][:campaign] &&
      ge_participant.exchange_participant.campaign = campaign
  end

  def ge_participant_params
    nested_params.require(:ge_participant).permit(
      :spanish_level,
      exchange_participant_attributes: %i[
        id fullname email birthdate cellphone local_committee_id
        university_id college_course_id password scholarity
        campaign_id
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
             :password, :scholarity, :campaign_id)
  end

  def english_level_params
    params[:ge_participant]
      .slice(:english_level)
  end

  def ge_participant_fields
    {
      'email' => ge_participant.email,
      'fullname' => ge_participant.fullname,
      'cellphone' => ge_participant.cellphone,
      'birthdate' => ge_participant.birthdate,
      'source' => ge_participant.exchange_participant.campaign.source,
      'medium' => ge_participant.exchange_participant.campaign.medium,
      'campaign' => ge_participant.exchange_participant.campaign.campaign,
      'podio_app' => 170_576_29
    }
  end
end
