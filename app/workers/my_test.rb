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

    sqs_msg.delete if ExpaApplicationSync.save_ogx_application(application)
    #ap = RepositoryExpaApi.map_applications(application)
    #sqs_msg.delete if RepositoryApplication.save_icx_from_expa(ap)
  end
end
