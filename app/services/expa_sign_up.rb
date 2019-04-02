require 'slack-notifier'
require 'concerns/check_person_present'
require 'open-uri'

class ExpaSignUp
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
    send_data_to_expa(@exchange_participant)

    notify_slack("Error synching EP:\n#{@exchange_participant.fullname} - #{@exchange_participant.email} on ENV: #{ENV['ENV']}") unless @status

    @status
  end

  private

  def notify_slack(message)
    notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'] do
      defaults channel: "##{ENV['SLACK_CHANNEL']}",
               username: "notifier"
    end

    notifier.ping(message)
  end

  def submit_data(exchange_participant)
    HTTParty.post(
      'https://auth.aiesec.org/users/',
      body: body_params
    )
  end

  def body_params
    params = {
      'authenticity_token' => authenticity_token,
      'utf8' => '✓',
      'user[email]' => exchange_participant.email,
      'user[first_name]' => exchange_participant.first_name,
      'user[last_name]' => exchange_participant_last_name(exchange_participant.last_name),
      'user[password]' => exchange_participant.decrypted_password,
      'user[phone]' => exchange_participant.cellphone,
      'user[country]' => ENV['EXPA_COUNTRY'],
      'user[mc]' => ENV['EXPA_MC_ID'],
      'user[lc]' => exchange_participant.local_committee.expa_id,
      'user[lc_input]' => exchange_participant.local_committee.expa_id,
      'user[allow_phone_communication]' =>
        exchange_participant.cellphone_contactable
    }

    params['user[alignment_id]'] = exchange_participant.university.expa_id if ENV['COUNTRY'] == 'per'
    params['user[referral_type'] = peruvian_referral_type(exchange_participant.referral_type) if ENV['COUNTRY'] == 'per'

    params
  end

  def exchange_participant_last_name(last_name)
    unless last_name.empty?
      last_name
    else
      '-'
    end
  end

  def send_data_to_expa(exchange_participant)
    submit_data(exchange_participant)
    id = exchange_participant_expa_id(exchange_participant)
    unless id.nil?
      @status = true if exchange_participant.update_attributes(expa_id: id)
    end
  end

  def exchange_participant_expa_id(exchange_participant)
    EXPAAPI::Client.query(
      ExistsQuery,
      variables: { email: exchange_participant.email }
    ).data&.check_person_present&.id
  end

  def authenticity_token
    sign_up_page.css('.signup_op [name=authenticity_token]').first['value']
  end

  def sign_up_page
    Nokogiri::HTML(open('https://auth.aiesec.org/users/sign_in'))
  end

  def peruvian_referral_type(params, exchange_participant)
    translations = {
      'facebook' => 0,
      'instagram' => 1,
      'amigo o familia' => 2,
      'publicidad universitaria' => 3,
      'otro' => 4
    }

    translations.key(exchange_participant.referral_type)
  end
end
