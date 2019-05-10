class ExchangeStudentHostToPodio
  def self.call(params)
    new(params).call
  end

  attr_reader :status, :exchange_student_host

  def initialize(params)
    @exchange_student_host = ExchangeStudentHost.find(params['exchange_student_host_id'])

    @status = false
  end

  def call
    unless Podio.client
      setup_podio
      authenticate_podio
    end

    podio_sync

    @exchange_student_host.reload

    @status = true if @exchange_student_host.podio_id
  end

  private

  def podio_sync
    podio_id = Podio::Item.create(22785246, fields: podio_params).item_id unless @exchange_student_host.podio_id

    @exchange_student_host.update_attribute(:podio_id, podio_id) if podio_id
  end

   def podio_params
    params = {
      'titulo' => @exchange_student_host.fullname,
      'email' => [{ 'type' => 'home', 'value' => @exchange_student_host.email }],
      'telefone' => [{ 'type' => 'home', 'value' => @exchange_student_host.cellphone }],
      'aiesec-mais-proxima' => @exchange_student_host.local_committee.podio_id,
      'cep' => @exchange_student_host.zipcode,
      'bairro' => @exchange_student_host.neighborhood,
      'cidade' => @exchange_student_host.city,
      'estado' => fetch_state,
      'quero-ser-contactado-por-telefone' => @exchange_student_host.cellphone_contactable ? 1 : 2
    }

    params
  end

   def fetch_state
    items = Podio::Item.find_by_filter_values(
        '13101818',
        'abreviacao': @exchange_student_host.state.downcase
    ).all.first.item_id
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
end
