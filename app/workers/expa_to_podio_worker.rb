class ExpaToPodioWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'expa_to_podio'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if ExpaToPodio.call(body)
  end
end
