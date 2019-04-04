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

    if ENV['COUNTRY'] == 'per'
      params['user[alignment_id]'] = exchange_participant.university.expa_id

      referral_type = peruvian_referral_type(exchange_participant.referral_type) if exchange_participant.referral_type > 0
      exchange_reason = peruvian_exchange_reason(exchange_participant.exchange_reason, exchange_participant.registerable_type)
      params['user[referral_type'] = "#{referral_type}&#{exchange_reason}"

      when_can_travel = exchange_participant.registerable.when_can_travel
      params['user[profile][earliest_start_date]'] = peruvian_earliest_start_date(when_can_travel) if when_can_travel < 3

      params['user[selected_programmes]'] = [peruvian_program(exchange_participant.registerable.class.name)]
    end

    puts params

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
end
