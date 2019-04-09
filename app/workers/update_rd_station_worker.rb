class UpdateRdStationWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'update_rd_station'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if UpdateRdStation.call(body)
  end
end
