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
        password: @exchange_participant.password,
        lc: @exchange_participant.local_committee.expa_id,
        mc: ENV['EXPA_MC_ID'],
        allow_phone_communication: @exchange_participant.cellphone_contactable,
        created_via: "json"
      }
    }.to_json
  end

  def update_exchange_participant_id
    @exchange_participant.update_attribute(:expa_id, @res.parsed_response['person_id'])
  end
end
