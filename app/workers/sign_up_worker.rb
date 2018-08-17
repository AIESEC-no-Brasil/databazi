class SignUpWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'sign_up_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(_sqs_msg, body)
    ExpaSignUp.call(body)
  end
end
