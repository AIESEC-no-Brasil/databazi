require 'ostruct'

class MyTestWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'temp'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sleep(30)
    application = JSON.parse(body['data'].to_json, object_class: OpenStruct)
    
    ap = RepositoryExpaApi.map_applications(application)
    if application&.opportunity&.programme&.short_name_display == 'TMP'
      sqs_msg.delete
    elsif RepositoryApplication.save_icx_from_expa(ap)
      sqs_msg.delete
    end
  end
end
