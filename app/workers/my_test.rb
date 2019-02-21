require 'ostruct'

class MyTestWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'temp'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    p body['data']
    #pqp = Struct.new(body['data'].keys).new(body['data'].values)

    json_object = JSON.parse(body['data'].to_json, object_class: OpenStruct)

    p json_object
    
    
    ap = RepositoryExpaApi.map_applications(json_object)
    p ap
    sqs_msg.delete if RepositoryApplication.save_icx_from_expa(ap)
    #sqs_msg.delete if SendToPodio.call(body)
  end
end
