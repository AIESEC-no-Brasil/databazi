class GtParticipantsController < ApplicationController
  expose :gt_participant

  def create
    if gt_participant.save
      render json: { status: :success }
    else
      render json: {
        status: :failure,
        messages: gt_participant.errors.messages
      }
    end
  end

  private

  def gt_participant_params
    nested_params.require(:gt_participant).permit(
      :scholarity, :experience,
      exchange_participant_attributes: [ :id, :fullname, :email, :birthdate, :cellphone ],
      english_level_attributes: [ :english_level ])
  end

  def nested_params
    ActionController::Parameters.new(
      gt_participant: {
        scholarity: params[:gt_participant][:scholarity],
        experience: params[:gt_participant][:experience],
        exchange_participant_attributes: exchange_participant_params,
        english_level_attributes: english_level_params
      }
    )
  end

  def exchange_participant_params
    params[:gt_participant]
    .slice(:id, :birthdate, :fullname, :email, :cellphone)
  end

  def english_level_params
    params[:gt_participant]
    .slice(:english_level)
  end
end
