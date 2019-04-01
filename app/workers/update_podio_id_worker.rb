class UpdatePodioIdWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'update_podio_id'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if UpdatePodioId.call(body)
  end
end
