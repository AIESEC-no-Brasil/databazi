class SurveyProcessorWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'survey_processor'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if SurveyProcessor.call(body)
  end
end
