class ExchangeStudentHostWorker
  include Shoryuken::Worker

   QUEUE_NAME = 'exchange_student_host'.freeze

   shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

   def perform(sqs_msg, body)
    sqs_msg.delete if ExchangeStudentHostToPodio.call(body)
  end
end
