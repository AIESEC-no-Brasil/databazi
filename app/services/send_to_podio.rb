class SendToPodio
  UNIVERSITY_ID_PATTERN = /^Universidade[0-9]*$/
  @@expires_at = 0

  def self.call(params)
    new(params).call
  end

  attr_reader :params, :status

  def initialize(params)
    @params = params
    @status = true
  end

  def call
    Shoryuken.logger.info("=>SQS PARAMS:\n=>#{@params}\n=>SQS PARAMS END")

    @status = send_to_podio(@params)
  end

  private

  def send_to_podio(params)
    params['podio_app'] ||= ENV['PODIO_APP_GV']

    if expired_token?
      setup_podio
      auth = authenticate_podio
      @@expires_at = auth.expires_at
    end

    Podio::Item.create(params['podio_app'], fields: podio_item_fields(params))
  end

  def expired_token?
    Podio.client.nil? || @@expires_at == 0 || @@expires_at < (Time.now + 600)
  end

  def authenticate_podio
    Podio.client.authenticate_with_credentials(
      ENV['PODIO_USERNAME'], ENV['PODIO_PASSWORD']
    )
  end

  def setup_podio
    Podio.setup(
      api_key: ENV['PODIO_API_KEY'],
      api_secret: ENV['PODIO_API_SECRET']
    )
  end

  def podio_item_fields(sqs_params)
    params = {
      'data-inscricao' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
      'title' => sqs_params['fullname'],
      'email' => [{ 'type' => 'home', 'value' => sqs_params['email'] }],
      'telefone' => [{ 'type' => 'home', 'value' => sqs_params['cellphone'] }],
      'data-de-nascimento' => {
        start: Date.parse(sqs_params['birthdate']).strftime('%Y-%m-%d %H:%M:%S')
      }
    }

    params['tag-origem'] = sqs_params['utm_source'] if sqs_params['utm_source']
    params['tag-meio'] = sqs_params['utm_medium'] if sqs_params['utm_medium']
    params['tag-campanha'] = sqs_params['utm_campaign'] if sqs_params['utm_campaign']
    params['tag-termo'] = sqs_params['utm_term'] if sqs_params['utm_term']
    params['tag-conteudo-2'] = sqs_params['utm_content'] if sqs_params['utm_content']
    params['escolaridade'] = sqs_params['scholarity'] if sqs_params['scholarity']
    params['cl-marcado-no-expa-nao-conta-expansao-ainda'] = sqs_params['local_committee'] if sqs_params['local_committee']
    params['nivel-de-ingles'] = sqs_params['english_level'] if sqs_params['english_level']
    params['nivel-de-espanhol'] = sqs_params['spanish_level'] if sqs_params['spanish_level']
    params['universidade'] = sqs_params['university'].to_i if sqs_params['university']
    params['curso'] = sqs_params['college_course'].to_i if sqs_params['college_course']
    params['sub-produto'] = sqs_params['experience'] if sqs_params['experience']
    if sqs_params['cellphone_contactable']
      params['gostaria-de-ser-contactado-por-celular'] =
        cellphone_contactable_option(sqs_params['cellphone_contactable'])
    end
    if params['nivel-de-ingles']
      params['nivel-de-ingles'] = 5 if params['nivel-de-ingles'].zero?
    end
    if params['nivel-de-espanhol']
      params['nivel-de-espanhol'] = 5 if params['nivel-de-espanhol'].zero?
    end
    params
  end

  def cellphone_contactable_option(value)
    value ? 1 : 2
  end
end
