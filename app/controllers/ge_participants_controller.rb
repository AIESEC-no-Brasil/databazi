class GeParticipantsController < ApplicationController
  include ExchangeParticipantable

  expose :ge_participant
  expose :exchange_participantable, -> { ge_participant }

  private

  def ge_participant_params
    nested_params.require(:ge_participant).permit(
      :spanish_level,
      exchange_participant_attributes: %i[
        id fullname email birthdate cellphone local_committee_id
        university_id college_course_id password
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
             :local_committee_id, :university_id, :college_course_id, :password)
  end

  def english_level_params
    params[:ge_participant]
      .slice(:english_level)
  end
end
