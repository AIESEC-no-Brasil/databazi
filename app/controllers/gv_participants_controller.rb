class GvParticipantsController < ApplicationController
  include ExchangeParticipantable

  expose :gv_participant
  expose :exchange_participantable, -> { gv_participant }

  private

  def gv_participant_params
    nested_params
      .require(:gv_participant)
      .permit(exchange_participant_attributes: %i[
                id fullname birthdate email cellphone local_committee_id
                university_id college_course_id password
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
             :local_committee_id, :university_id, :college_course_id, :password)
  end
end
