require 'concerns/check_person_present'
require 'open-uri'

class ExpaSignUp
  def self.call(params)
    new(params).call
  end

  attr_reader :exchange_participant, :status

  def initialize(params)
    @status = true
    @exchange_participant = ExchangeParticipant.find_by(
      id: params['exchange_participant_id']
    )
  end

  def call
    @status = send_data_to_expa(@exchange_participant)

    @status
  end

  private

  def submit_data(exchange_participant)
    HTTParty.post(
      'https://auth.aiesec.org/users/',
      body: {
        'authenticity_token' => authenticity_token,
        'utf8' => '✓',
        'user[email]' => exchange_participant.email,
        'user[first_name]' => exchange_participant.first_name,
        'user[last_name]' => exchange_participant.last_name,
        'user[password]' => exchange_participant.decrypted_password,
        'user[phone]' => exchange_participant.cellphone,
        'user[country]' => country_name,
        'user[mc]' => mc_id,
        'user[lc]' => exchange_participant.local_committee.expa_id,
        'user[lc_input]' => exchange_participant.local_committee.expa_id,
        'user[allow_phone_communication]' => exchange_participant.cellphone_contactable
      }
    )
  end

  def country_name
    Rails.application.credentials[ENV['COUNTRY'].to_sym][:country]
  end

  def mc_id
    Rails.application.credentials[ENV['COUNTRY'].to_sym][:mc_id]
  end

  def send_data_to_expa(exchange_participant)
    submit_data(exchange_participant)
    exchange_participant_present?(exchange_participant)
  end

  def exchange_participant_present?(exchange_participant)
    EXPAAPI::Client.query(
      ExistsQuery,
      variables: { email: exchange_participant.email }
    ).data&.check_person_present?
  end

  def authenticity_token
    sign_up_page.css('.signup_op [name=authenticity_token]').first['value']
  end

  def sign_up_page
    Nokogiri::HTML(open('https://auth.aiesec.org/users/sign_in'))
  end
end
