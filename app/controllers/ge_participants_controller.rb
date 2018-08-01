class GeParticipantsController < ApplicationController
  expose :ge_participant

  def create
    if ge_participant.save
      render json: { status: :success }
    else
      render json: {
        status: :failure,
        messages: ge_participant.errors.messages
      }
    end
  end

  private

  def ge_participant_params
    nested_params.require(:ge_participant).permit(
      :spanish_level,
      exchange_participant_attributes: [
        :id, :fullname, :email, :birthdate, :cellphone, :local_committee_id,
        :university_id, :college_course_id, :password
      ],
      english_level_attributes: [ :english_level ])
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
    .slice(:id, :birthdate, :fullname, :email, :cellphone, :local_committee_id,
      :university_id, :college_course_id, :password)
  end

  def english_level_params
    params[:ge_participant]
    .slice(:english_level)
  end
end
