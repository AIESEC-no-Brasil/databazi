class MembershipsController < ApplicationController
  expose :membership

  def create
    if membership.save
      perform_on_workers
      render json: { status: :success }
    else
      render json: {
        status: :failure,
        messages: membership.errors.messages
      }
    end
  end

  private

  def perform_on_workers
    MembershipWorker.perform_async({ membership_id: membership.id })
  end

  def membership_params
    params.require(:membership).permit(
      :fullname, :cellphone, :birthdate, :email, :city,
      :state, :cellphone_contactable, :college_course_id,
      :nearest_committee
    )
  end
end
