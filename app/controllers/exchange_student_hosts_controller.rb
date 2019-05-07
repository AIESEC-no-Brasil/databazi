class ExchangeStudentHostsController < ApplicationController
  expose :exchange_student_host

  def create
    if exchange_student_host.save
      perform_on_workers
      render json: { status: :success }
    else
      render json: {
        status: :failure,
        messages: exchange_student_host.errors.messages
      }
    end
  end

  private

  def perform_on_workers
    ExchangeStudentHostWorker.perform_async(exchange_student_host.as_sqs)
  end

  def exchange_student_host_params
    params.require(:exchange_student_host).permit(
      :fullname, :email, :cellphone, :zipcode,
      :neighborhood, :city, :state, :cellphone_contactable, :local_committee_id)
  end
end
