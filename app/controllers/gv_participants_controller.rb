class GvParticipantsController < ApplicationController
	expose :gv_participant

  def create
		if gv_participant.save
			render json: { status: :success }
		else
			render json: { status: :failure }
		end
  end

	private

	def gv_participant_params
		exchange_params = params[:gv_participant]
			.slice(:id, :birthdate, :fullname, :email, :cellphone)
		ActionController::Parameters.new(
			gv_participant: { exchange_participant_attributes: exchange_params }
		).require(:gv_participant)
		.permit!
	end
end
