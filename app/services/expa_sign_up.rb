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

    if @res.code == 201
      update_exchange_participant_id
      send_mail if @exchange_participant.prospect_signup_source?
    end

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
        selected_programmes: [selected_programme(@exchange_participant.registerable.class.name).to_s],
        allow_phone_communication: @exchange_participant.cellphone_contactable,
        created_via: "json",
        referral_type: "#{referral_type_translation(@exchange_participant.try(:referral_type))}&#{@exchange_participant.try(:exchange_reason)}",
      }
    }.to_json
  end

  def referral_type_translation(referral_type)
    return 'Altro' unless referral_type

    {
      'facebook_ad' => 'Facebook',
      'instagram_ad' => 'Instagram',
      'friend' => 'Amici',
      'teacher' => 'Professore',
      'event_or_fair' => 'Evento',
      'flyer' => 'Volantini o Poster',
      'search_engine' => 'Motore di ricerca',
      'email' => 'Email',
      'other_website' => 'Altre Sitio Web',
      'other' => 'Altro',
      'class_presentation' => 'Presentazione in classe',
      'informative_banquet' => 'Banchetto informativo'
    }[referral_type]
  end

  def selected_programme(program)
    programmes = { gv_participant: 1, gt_participant: 2, ge_participant: 5 }

    programmes[program_snake_case(program).to_sym]
  end

  def program_snake_case(program)
    program.underscore.downcase
  end

  def update_exchange_participant_id
    @exchange_participant.update_attributes(expa_id: @res.parsed_response['person_id'])
  end

  def send_mail
    Utils::SesSendMail.call(@exchange_participant.id)
  end
end
