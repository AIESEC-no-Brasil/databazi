class GtParticipantsController < ApplicationController
  include ExchangeParticipantable
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
      params[:gt_participant][:utm_medium] &&
      params[:gt_participant][:utm_campaign] &&
      params[:gt_participant][:utm_term] &&
      params[:gt_participant][:utm_content]
  end

  def gt_participant_params
    nested_params.require(:gt_participant).permit(
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
      campaign_id cellphone_contactable
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
        scholarity: params[:gt_participant][:scholarity],
        english_level_attributes: english_level_params,
        exchange_participant_attributes: exchange_participant_params,
        experience_attributes: experience_params
      }
    )
  end

  def english_level_params
    params[:gt_participant]
      .slice(:english_level)
  end

  def exchange_participant_params
    params[:gt_participant]
      .slice(:id, :birthdate, :fullname, :email, :cellphone,
             :local_committee_id, :university_id, :college_course_id,
             :password, :scholarity, :campaign_id, :cellphone_contactable)
  end

  def experience_params
    params[:gt_participant][:experience]
      .slice(:id, :language, :marketing, :information_technology, :management)
  end

  def gt_participant_fields
    {
      'email' => gt_participant.email, 'fullname' => gt_participant.fullname,
      'cellphone' => gt_participant.cellphone,
      'birthdate' => gt_participant.birthdate,
      'utm_source' => utm_source, 'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign, 'utm_term' => utm_term,
      'utm_content' => utm_content, 'podio_app' => podio_app_id,
      'scholarity' => scholarity_human_name,
      'local_committee' => gt_participant.exchange_participant&.local_committee&.podio_id,
      'english_level' => gt_participant&.english_level&.read_attribute_before_type_cast(:english_level),
      'university' => gt_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => gt_participant.exchange_participant&.college_course&.podio_item_id,
      'experience' => gt_participant&.experience&.for_podio,
      'cellphone_contactable' => gt_participant.exchange_participant.cellphone_contactable
    }
  end

  def podio_app_id
    ENV['PODIO_APP_GT']
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
