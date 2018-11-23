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
    params['podio_app'] ||= 152_908_22

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
      ENV['PODIO_USERNAME'],
      ENV['PODIO_PASSWORD']
    )
  end

  def setup_podio
    Podio.setup(
      api_key: ENV['PODIO_API_KEY'],
      api_secret: ENV['PODIO_API_SECRET']
    )
  end

  def podio_item_fields(params)
    ENV['COUNTRY'] == 'bra'
      podio_item_fields_bra(params)
    else
      podio_item_fields_arg(params)
    end
  end

  def podio_item_fields_arg(sqs_params)
    if sqs_params['podio_app'] == ENV['PODIO_APP_GV']
      podio_item_fields_arg_gv(sqs_params)
    elsif sqs_params['podio_app'] == ENV['PODIO_APP_GT']
      podio_item_fields_arg_gt(sqs_params)
    elsif sqs_params['podio_app'] == ENV['PODIO_APP_GE']
      podio_item_fields_arg_ge(sqs_params)
    else
      podio_item_fields_arg_gv(sqs_params)
    end
  end

  def podio_item_fields_arg_gv(sqs_params)
    params = {
      'fecha-de-inscripicion' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
      'nombre-completo' => sqs_params['fullname'],
      'mail' => [{ 'type' => 'home', 'value' => sqs_params['email'] }],
      'telefono' => [{ 'type' => 'home', 'value' => sqs_params['cellphone'] }],
      'fecha-de-nacimiento' => {
        start: Date.parse(sqs_params['birthdate']).strftime('%Y-%m-%d %H:%M:%S')
      }
    }

    params['nivel-de-escolaridad'] = sqs_params['scholarity'] if sqs_params['scholarity']
    params['local-committee'] = sqs_params['local_committee'] if sqs_params['local_committee']
    params['universidad'] = sqs_params['university'].to_i if sqs_params['university']
    params['otra-universidad'] = sqs_params['other_university'] if sqs_params['other_university']
    params['campo-de-estudio'] = sqs_params['college_course'].to_i if sqs_params['college_course']
    params['cuando-usted-puede-viajar'] = sqs_params['when_can_travel'].to_i if sqs_params['when_can_travel']

    params
  end

  def podio_item_fields_arg_gt(sqs_params)
    params = {
      'fecha-de-inscripicion' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
      'titulo' => sqs_params['fullname'],
      'mail' => [{ 'type' => 'home', 'value' => sqs_params['email'] }],
      'telefono' => [{ 'type' => 'home', 'value' => sqs_params['cellphone'] }],
      'fecha-de-nacimiento' => {
        start: Date.parse(sqs_params['birthdate']).strftime('%Y-%m-%d %H:%M:%S')
      }
    }

    params['nivel-de-escolaridad'] = sqs_params['scholarity'] if sqs_params['scholarity']
    params['segmentacion-caba'] = sqs_params['local_committee'] if sqs_params['local_committee']
    params['nivel-de-ingles'] = sqs_params['english_level'] if sqs_params['english_level']
    params['nivel-de-espanhol'] = sqs_params['spanish_level'] if sqs_params['spanish_level']
    params['universidad'] = sqs_params['university'].to_i if sqs_params['university']
    params['otra-universidad'] = sqs_params['other_university'] if sqs_params['other_university']
    params['campo-de-estudio-2'] = sqs_params['college_course'].to_i if sqs_params['college_course']
    params['cv'] = sqs_params['curriculum'] if sqs_params['curriculum']
    params['destino-de-preferencia'] = sqs_params['preferred_destination'] if sqs_params['preferred_destination']

    params
  end

  def podio_item_fields_arg_ge(sqs_params)
    params = {
      'fecha-de-inscripicion' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
      'titulo' => sqs_params['fullname'],
      'mail' => [{ 'type' => 'home', 'value' => sqs_params['email'] }],
      'telefono' => [{ 'type' => 'home', 'value' => sqs_params['cellphone'] }],
      'fecha-de-nacimiento' => {
        start: Date.parse(sqs_params['birthdate']).strftime('%Y-%m-%d %H:%M:%S')
      }
    }

    params['nivel-de-escolaridad'] = sqs_params['scholarity'] if sqs_params['scholarity']
    params['oficina-de-aiesec-mas-cercana'] = sqs_params['local_committee'] if sqs_params['local_committee']
    params['nivel-de-ingles'] = sqs_params['english_level'] if sqs_params['english_level']
    params['nivel-de-espanhol'] = sqs_params['spanish_level'] if sqs_params['spanish_level']
    params['universidad'] = sqs_params['university'].to_i if sqs_params['university']
    params['otra-universidad'] = sqs_params['other_university'] if sqs_params['other_university']
    params['campo-de-estudio-2'] = sqs_params['college_course'].to_i if sqs_params['college_course']
    params['adjuntaste-tu-cv-preferible-cv-de-1-pagina'] = sqs_params['curriculum'] if sqs_params['curriculum']
    params['donde-te-gustaria-vivir-esa-esa-experiencia'] = sqs_params['preferred_destination'] if sqs_params['preferred_destination']
    params['fechas-de-disponibilidad'] = sqs_params['when_can_travel'].to_i if sqs_params['when_can_travel']

    params
  end

  def podio_item_fields_bra(sqs_params)
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
    params['gostaria-de-ser-contactado-por-celular'] = cellphone_contactable_option(sqs_params['cellphone_contactable'])
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
