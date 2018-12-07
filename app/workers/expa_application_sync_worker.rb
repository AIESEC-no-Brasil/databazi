class ExpaApplicationSyncWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'databazi_expa_application_sync_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if ExpaApplicationSync.call(body)
  end
end
