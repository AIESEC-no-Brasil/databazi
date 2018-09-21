class GvParticipantsController < ApplicationController
  include ExchangeParticipantable
  before_action :campaign_sign_up

  expose :gv_participant
  expose :exchange_participantable, -> { gv_participant }
  expose :ep_fields, -> { gv_participant_fields }
  expose :campaign, lambda {
    Campaign.where(source: params[:gv_participant][:source],
                   medium: params[:gv_participant][:medium],
                   campaign: params[:gv_participant][:campaign]).first_or_create
  }

  private

  def campaign_sign_up
    params[:gv_participant][:source] && params[:gv_participant][:medium] &&
      params[:gv_participant][:campaign] &&
      gv_participant.exchange_participant.campaign = campaign
  end

  def gv_participant_params
    nested_params
      .require(:gv_participant)
      .permit(exchange_participant_attributes: %i[
                id fullname birthdate email cellphone local_committee_id
                university_id college_course_id password scholarity
                campaign_id
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
             :password, :scholarity, :campaign_id)
  end

  def gv_participant_fields
    {
      'email' => gv_participant.email,
      'fullname' => gv_participant.fullname,
      'cellphone' => gv_participant.cellphone,
      'birthdate' => gv_participant.birthdate,
      'source' => gv_participant.exchange_participant.campaign.source,
      'medium' => gv_participant.exchange_participant.campaign.medium,
      'campaign' => gv_participant.exchange_participant.campaign.campaign,
      'podio_app' => 152_908_22
    }
  end
end
