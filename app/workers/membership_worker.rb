class MembershipWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'membership_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if MembershipToPodio.call(body)
  end
end
