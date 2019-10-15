class ImpactBrazilWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'impact_brazil_referral'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if ImpactBrazil.call(body)
  end
end
