class UpdateRdStation
  def self.call(params)
    new(params).call
  end

  attr_reader :exchange_participant, :status

  def initialize(params)
    @status = false
    @exchange_participant = ExchangeParticipant.find_by(
      id: params['exchange_participant_id']
    )
  end

  def call
    update_rd_lead

    @status
  end

  private

  def update_rd_lead
    access_token = rdstation_authentication_token

    contact = RDStation::Contacts.new(access_token)
    lead = contact.by_email('apr08gv1@devmagic.com.br')

    updated_lead = contact.update(lead['uuid'], contact_info)

    check_status(updated_lead)
  end

  def check_status(updated_lead)
    @status = true if updated_lead['email'] == @exchange_participant.email
  end

  def contact_info
    {
      cf_persona: peruvian_exchange_reason(@exchange_participant.exchange_reason, @exchange_participant.registerable.class.name),
      cf_referral: peruvian_referral_type(@exchange_participant.referral_type)
    }
  end

  def peruvian_exchange_reason(exchange_reason, program)
    gv_participant = ['Intelectual', 'Turista', 'Altruista', 'Otra']
    ge_participant = ['Profesional', 'Viajero', 'Estudioso', 'Otra']
    gt_participant = ['Oportunidades', 'Profesional', 'Networking', 'Otra']

    eval(program_snake_case(program)).fetch(exchange_reason)
  end

  def peruvian_referral_type(referral_type)
    translations = {
      'facebook' => 1,
      'instagram' => 2,
      'amigo o familia' => 3,
      'evento em mi universidad' => 4,
      'publicidad universitaria' => 5,
      'otro' => 6
    }

    translations.key(referral_type)
  end

  def program_snake_case(program)
    program.underscore.downcase
  end

  def rdstation_authentication_token
    rdstation_authentication = RDStation::Authentication.new(ENV['RDSTATION_CLIENT_ID'], ENV['RDSTATION_CLIENT_SECRET'])
    rdstation_authentication.auth_url(ENV['RDSTATION_REDIRECT_URL'])

    rdstation_authentication.update_access_token(ENV['RDSTATION_REFRESH_TOKEN'])['access_token']
  end
end
