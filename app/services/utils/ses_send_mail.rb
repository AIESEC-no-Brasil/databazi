module Utils
  class SesSendMail
    require 'aws-sdk-rails'

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @exchange_participant = ExchangeParticipant.find(params)
    end

    def call
      ses = new_ses_mailer

      begin
        res = ses.send_email({
          destination: {
            to_addresses: [
              recipient,
            ],
          },
          message: {
            body: {
              html: { charset: encoding, data: html_body },
              text: { charset: encoding, data: text_body },
            },
            subject: {
              charset: encoding,
              data: subject,
            },
          },
        source: sender
        })

        res
      rescue Aws::SES::Errors::ServiceError => exception
        Raven.capture_exception(exception)
      end
    end

    private

    def new_ses_mailer
      Aws::SES::Client.new(region: ENV['MAILER_AWS_REGION'],
                          credentials: Aws::Credentials.new(ENV['MAILER_AWS_ACCESS_KEY_ID'], ENV['MAILER_AWS_SECRET_ACCESS_KEY']))
    end

    def sender
      ENV['MAILER_EMAIL']
    end

    def recipient
      @exchange_participant.email
    end

    def subject
      'aiesec.org - informativo de dados cadastrais'
    end

    def text_body
      "Bem-vindo a AIESEC! Seus dados de acesso são de acesso ao portal https://aiesec.org.br e-mail: #{recipient} e senha: #{password}"
    end

    def html_body
      '<h1>Seja bem-vindo a AIESEC!</h1>'\
      '<p>Seus dados de acesso ao portal <a href="https://aiesec.org">aiesec.org</a> são:</br>'\
      "<ul><li>e-mail: #{recipient}</li><li>senha: #{password}</li></ul>"
    end

    def password
      @exchange_participant.decrypted_password
    end

    def encoding
      'UTF-8'
    end
  end
end
