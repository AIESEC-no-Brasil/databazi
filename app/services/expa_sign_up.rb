class ExpaSignUp
  def self.call(params)
    new(params).call
  end

  attr_reader :exchange_participant, :status

  def initialize(params)
    @status = true
    @exchange_participant = ExchangeParticipant.find_by(id: params)
  end

  def call
    @status = send_data_to_expa(@exchange_participant)

    @status
  end

  private

  def send_data_to_expa(exchange_participant)
    page = sign_in_page

    auth_form = page.forms[1]
    auth_form.field_with(name: 'user[email]').value =
      exchange_participant.email
    auth_form.field_with(name: 'user[first_name]').value =
      exchange_participant.first_name
    auth_form.field_with(name: 'user[last_name]').value =
      exchange_participant.last_name
    auth_form.field_with(name: 'user[password]').value =
      exchange_participant.decrypted_password
    auth_form.field_with(name: 'user[phone]').value =
      exchange_participant.cellphone
    auth_form.field_with(name: 'user[country]').value = 'Brazil'
    auth_form.field_with(name: 'user[mc]').value = '1606'
    auth_form.field_with(name: 'user[lc]').value =
      exchange_participant.local_committee.expa_id
    auth_form.field_with(name: 'user[lc_input]').value =
      exchange_participant.local_committee.expa_id
    auth_form.field_with(name: 'user[allow_phone_communication]').value =
      exchange_participant.cellphone_contactable
    auth_form.checkbox_with(name: 'user[allow_phone_communication]').checked =
      exchange_participant.cellphone_contactable

    page = agent.submit(auth_form, auth_form.buttons.first)
    page.code.to_i == 200 &&
      EXPA::Client.new.auth(exchange_participant.email,
                            exchange_participant.decrypted_password)
  end

  def agent
    Mechanize.new do |a|
      a.ssl_version = 'TLSv1'
      a.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def sign_in_page
    agent.get('https://auth.aiesec.org/users/sign_in')
  end
end
