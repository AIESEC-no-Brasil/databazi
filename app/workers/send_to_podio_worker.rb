class SendToPodioWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'databazi_podio_queue_new'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    if ENV['COUNTRY_MODULE'] == 'Brazil'
      integrator = eval(ENV['COUNTRY_MODULE'] + "::PodioOgxIntegrator")

      SendToPodio.call(body)
      sqs_msg.delete if integrator.call(body)
    else
      sqs_msg.delete if SendToPodio.call(body)
    end
  end
end
