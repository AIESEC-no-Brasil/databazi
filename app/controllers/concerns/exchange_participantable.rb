module ExchangeParticipantable
  extend ActiveSupport::Concern
  def create
    if exchange_participantable.save
      SendToPodioWorker.perform_async(ep_fields)
      SignUpWorker.perform_async(exchange_participantable.as_sqs)
      render json: { status: :success }
    else
      campaign.destroy
      render json: {
        status: :failure,
        messages: exchange_participantable.errors.messages
      }
    end
  end
end
