class GvParticipantsController < ApplicationController
  include ExchangeParticipantable

  expose :gv_participant
  expose :exchange_participantable, -> { gv_participant }
  expose :ep_fields, -> { gv_participant_fields }

  private

  def gv_participant_params
    nested_params
      .require(:gv_participant)
      .permit(exchange_participant_attributes: %i[
                id fullname birthdate email cellphone local_committee_id
                university_id college_course_id password scholarity
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
             :password, :scholarity)
  end

  def gv_participant_fields
    {
      'email' => gv_participant.email,
      'fullname' => gv_participant.fullname,
      'cellphone' => gv_participant.cellphone,
      'birthdate' => gv_participant.birthdate,
      'podio_app' => 152_908_22
    }
  end
end
