class ResyncRdStationWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'resync_rd_station'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if UpdateRdStation.call(body)
    puts "Resync: #{body}"
    sleep(2)
  end
end
