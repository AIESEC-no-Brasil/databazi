require 'open-uri'

class ExpaSignUp
  def self.call(params)
    new(params).call
  end

  attr_accessor :res
  attr_reader :exchange_participant, :status

  def initialize(params)
    @exchange_participant = ExchangeParticipant.find_by(
      id: params['exchange_participant_id']
    )
  end

  def call
    @res = sign_up_user
    update_exchange_participant_id if @res.code == 201

    @res
  end

  private

  def sign_up_user
    HTTParty.post(ENV['EXPA_SIGNUP_URL'],
      body: payload,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def payload
    {
      user: {
        first_name: @exchange_participant.first_name,
        last_name: @exchange_participant.last_name,
        email: @exchange_participant.email,
        country_code: ENV['COUNTRY_CODE'],
        phone: @exchange_participant.cellphone,
        password: @exchange_participant.decrypted_password,
        lc: @exchange_participant.local_committee.expa_id,
        mc: ENV['EXPA_MC_ID'],
        allow_phone_communication: @exchange_participant.cellphone_contactable,
        selected_programmes: [peruvian_program(@exchange_participant.registerable.class.name)]
        alignment_id: @exchange_participant.university.expa_id,
        referral_type: "#{referral_type}&#{exchange_reason}",
        created_via: "json"
      }
    }.to_json
  end

  def update_exchange_participant_id
    @exchange_participant.update_attribute(:expa_id, @res.parsed_response['person_id'])
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

  def peruvian_exchange_reason(exchange_reason, program)
    gv_participant = ['Intelectual', 'Turista', 'Altruista', 'Otra']
    ge_participant = ['Profesional', 'Viajero', 'Estudioso', 'Otra']
    gt_participant = ['Oportunidades', 'Profesional', 'Networking', 'Otra']

    eval(program_snake_case(program)).fetch(exchange_reason)
  end

  def peruvian_program(program)
    programmes = { gv_participant: 1, gt_participant: 2, ge_participant: 5 }

    programmes[program_snake_case(program).to_sym]
  end

  def program_snake_case(program)
    program.underscore.downcase
  end

  def peruvian_earliest_start_date(when_can_travel)
    # as_soon_as_possible next_three_months next_six_months
    date = [ Time.now, Time.now + 3.months, Time.now + 6.months]

    # FIX-ME: check timezone
    (date[when_can_travel] + 3.hours).strftime('%Y-%m-%d')
  end

  def referral_type
    peruvian_referral_type(@exchange_participant.referral_type) if @exchange_participant.referral_type > 0
  end

  def exchange_reason
    peruvian_exchange_reason(@exchange_participant.exchange_reason, @exchange_participant.registerable_type)
  end

  def when_can_travel
    @exchange_participant.registerable.when_can_travel
  end

  def earliest_start_date
    peruvian_earliest_start_date(when_can_travel) if when_can_travel < 3
  end
end
