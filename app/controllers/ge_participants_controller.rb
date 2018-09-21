class GeParticipantsController < ApplicationController
  include ExchangeParticipantable

  expose :ge_participant
  expose :exchange_participantable, -> { ge_participant }
  expose :ep_fields, -> { ge_participant_fields }

  private

  def ge_participant_params
    nested_params.require(:ge_participant).permit(
      :spanish_level,
      exchange_participant_attributes: %i[
        id fullname email birthdate cellphone local_committee_id
        university_id college_course_id password scholarity
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
             :password, :scholarity)
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
      'podio_app' => 170_576_29
    }
  end
end
