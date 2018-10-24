class UpdateUniversitiesPodioWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'databazi_podio_deadletter_queue_new'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if SendToPodio.call(body)
  end
end
