class GvParticipantsController < ApplicationController
  expose :gv_participant

  def create
    if gv_participant.save
      render json: { status: :success }
    else
      render json: {
        status: :failure,
        messages: gv_participant.errors.messages
      }
    end
  end

  private

  def gv_participant_params
    nested_params.require(:gv_participant)
      .permit(exchange_participant_attributes: [
        :id, :fullname, :birthdate, :email, :cellphone, :local_committee_id,
        :university_id, :college_course_id
      ])
  end

  def nested_params
    ActionController::Parameters.new(
      gv_participant: { exchange_participant_attributes: exchange_participant_params }
    )
  end

  def exchange_participant_params
    params[:gv_participant]
    .slice(:id, :birthdate, :fullname, :email, :cellphone, :local_committee_id,
      :university_id, :college_course_id)
  end
end
