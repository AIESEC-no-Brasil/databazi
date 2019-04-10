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
    lead = contact.by_email(@exchange_participant.email)

    updated_lead = contact.update(lead['uuid'], contact_info)

    check_status(updated_lead)
  end

  def check_status(updated_lead)
    @status = true if updated_lead['email'] == @exchange_participant.email
  end

  def contact_info
    {
      cf_campo_de_estudio: @exchange_participant.college_course.try(:name),
      cf_ciudad: @exchange_participant.city,
      cf_experiencia_laboral: @exchange_participant.try(:work_experience),
      cf_persona: peruvian_exchange_reason(@exchange_participant.exchange_reason, @exchange_participant.registerable.class.name),
      cf_phone_communication: @exchange_participant.cellphone_contactable ? 'Sí' : 'No',
      cf_programa_de_interes: @exchange_participant.registerable_type.upcase[0..1],
      cf_referral: peruvian_referral_type(@exchange_participant.referral_type),
      cf_universidad: @exchange_participant.university.try(:name),
      cf_earliest_start_date: peruvian_earliest_start_date(@exchange_participant.created_at, @exchange_participant.when_can_travel),
      cf_fecha_de_nacimiento: @exchange_participant.birthdate.strftime('%Y-%m-%d')
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

  def peruvian_earliest_start_date(created_at, when_can_travel)
    # as_soon_as_possible next_three_months next_six_months
    date = [created_at, created_at + 3.months, created_at + 6.months]

    return '-' if when_can_travel >= date.length

    # FIX-ME: check timezone
    (date[when_can_travel]).strftime('%Y-%m-%d')
  end
end
