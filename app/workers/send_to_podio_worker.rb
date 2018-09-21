class SendToPodioWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'podio_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if SendToPodio.call(body)
  end
end
