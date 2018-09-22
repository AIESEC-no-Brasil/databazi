class SendToPodio
  def self.call(params)
    new(params).call
  end

  attr_reader :params, :status

  def initialize(params)
    @params = params
    @status = true
  end

  def call
    @status = send_to_podio(@params)
  end

  private

  def send_to_podio(params)
    params['podio_app'] ||= 152_908_22
    setup_podio
    authenticate_podio
    Podio::Item.create(params['podio_app'], fields: podio_item_fields(params))
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

  def podio_item_fields(params)
    {
      'data-inscricao' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
      'title' => params['fullname'],
      'email' => [{ 'type' => 'home', 'value' => params['email'] }],
      'telefone' => [{ 'type' => 'home', 'value' => params['cellphone'] }],
      'data-de-nascimento' => {
        start: Date.parse(params['birthdate']).strftime('%Y-%m-%d %H:%M:%S')
      },
      'tag-origem' => params['source'],
      'tag-meio' => params['medium'],
      'tag-campanha' => params['campaign']
    }
  end
end
