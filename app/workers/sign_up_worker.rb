class SignUpWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'databazi_sign_up_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if ExpaSignUp.call(body).code == 201
  end
end
