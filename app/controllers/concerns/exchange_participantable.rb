module ExchangeParticipantable
  extend ActiveSupport::Concern
  def create
    if exchange_participantable.save
      perform_on_workers
      render json: { status: :success }
    else
      remove_campaign
      render json: {
        status: :failure,
        messages: exchange_participantable.errors.messages
      }
    end
  end

  private

  def perform_on_workers
    SendToPodioWorker.perform_async(ep_fields)
    SignUpWorker.perform_async(exchange_participantable.as_sqs)
    UpdateRdStationWorkerUpdateRdStationWorker.perform_async(exchange_participantable.as_sqs) if ENV['COUNTRY'] == 'per'
  end

  def remove_campaign
    campaign.destroy
  end
end
