class ExchangeStudentHostToPodio
  def self.call(params)
    new(params).call
  end

   attr_reader :status, :exchange_student_host

   def initialize(params)
    puts params[:exchange_student_host_id]
    @exchange_student_host = ExchangeStudentHost.find(params[:exchange_student_host_id])

     @status = false
  end

   def call
    if expired_token?
      setup_podio
      auth = authenticate_podio
      @@expires_at = auth.expires_at
    end

     podio_sync

     @exchange_student_host.reload

     @status = true if @exchange_student_host.central_icx_podio_id && @exchange_student_host.icx_tests_podio_id
  end

   private

   def podio_sync
    icx_tests_sync
    central_icx_sync
  end

   def icx_tests_sync
    icx_tests_podio_id = Podio::Item.create(22529265, fields: podio_params).item_id unless @exchange_student_host.icx_tests_podio_id

     @exchange_student_host.update_attribute(:icx_tests_podio_id, icx_tests_podio_id) if icx_tests_podio_id
  end

   def central_icx_sync
    central_icx_podio_id = Podio::Item.create(20409291, fields: podio_params).item_id unless @exchange_student_host.central_icx_podio_id

     @exchange_student_host.update_attribute(:central_icx_podio_id, central_icx_podio_id) if central_icx_podio_id
  end

   def podio_params
    params = {
      'titulo' => @exchange_student_host.fullname,
      'email' => [{ 'type' => 'home', 'value' => @exchange_student_host.email }],
      'telefone' => [{ 'type' => 'home', 'value' => @exchange_student_host.cellphone }],
      'comite-local-mais-proximo' => @exchange_student_host.local_committee.podio_id,
      'cep' => @exchange_student_host.zipcode,
      'bairro' => @exchange_student_host.neighborhood,
      'cidade' => @exchange_student_host.city,
      'estado' => fetch_state
    }

     params
  end

   def fetch_state
    items = Podio::Item.find_by_filter_values(
        '13101818',
        'abreviacao': @exchange_student_host.state.downcase
      ).all.first.item_id
  end

   def expired_token?
    Podio.client.nil?
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
