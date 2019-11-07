class SignUpWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'databazi_sign_up_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    response_code = ExpaSignUp.call(body).code

    sqs_msg.delete if  response_code.in?([200, 422])
  end
end
