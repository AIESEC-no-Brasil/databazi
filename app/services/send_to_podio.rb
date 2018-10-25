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
      Rails.application.credentials.podio_username,
      Rails.application.credentials.podio_password
    )
  end

  def setup_podio
    Podio.setup(
      api_key: Rails.application.credentials.podio_api_key,
      api_secret: Rails.application.credentials.podio_api_secret
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
    params['universidade'] = podio_helper_find_item_by_unique_id(sqs_params['university'], 'universidade') if sqs_params['university']
    params['universidade'] = podio_helper_find_item_by_unique_id(fix_university_id(sqs_params['university']), 'universidade') if sqs_params['university']
    params['curso'] = podio_helper_find_item_by_unique_id(sqs_params['college_course'], 'curso') if sqs_params['college_course']
    params['sub-produto'] = sqs_params['experience'] if sqs_params['experience']
    params['nivel-de-ingles'] = 5 if params['nivel-de-ingles'].zero?
    params['nivel-de-espanhol'] = 5 if params['nivel-de-espanhol'].zero?

    params
  end

  def podio_helper_find_item_by_unique_id(unique_id, option)
    attributes = { sort_by: 'last_edit_on' }
    if option == 'universidade'
      app_id = 14_568_134
      attributes[:filters] = { 117_992_837 => unique_id }
    elsif option == 'curso'
      app_id = 14_568_143
      attributes[:filters] = { 117_992_834 => unique_id }
    end

    response = Podio.connection.post do |req|
      req.url "/item/app/#{app_id}/filter/"
      req.body = attributes
    end

    JSON.parse(Podio::Item.collection(response.body).first.to_json)[0]['id']
  end

  def fix_university_id(university_id)
    return nil unless university_id.present?
    return university_id if university_id.match? UNIVERSITY_ID_PATTERN

    university = University.find('name like :suffix', suffix: "%#{university_id}")
    university.podio_id
  end
end
