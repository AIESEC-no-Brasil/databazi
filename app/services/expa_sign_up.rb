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
    url = 'https://auth.aiesec.org/users/sign_in'
    page = agent.get(url)

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
    page.code.to_i == 200 && auth(exchange_participant.email, exchange_participant.decrypted_password)
  end

  def agent
    Mechanize.new do |a|
      a.ssl_version = 'TLSv1'
      a.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def auth(email, password)
    @url = 'https://auth.aiesec.org/users/sign_in'
    @url_op = 'https://aiesec.org/auth'
    @token = nil
    @max_age = nil
    @expiration_time = nil
    @email = email
    @password = password
    agent = Mechanize.new {|a| a.ssl_version, a.verify_mode = 'TLSv1',OpenSSL::SSL::VERIFY_NONE}
    page = agent.get(@url)
    aiesec_form = page.form()
    aiesec_form.field_with(:name => 'user[email]').value = @email
    aiesec_form.field_with(:name => 'user[password]').value = @password

    begin
      page = agent.submit(aiesec_form, aiesec_form.buttons.first)
    rescue => exception
      puts exception.to_s
      false
    else
      if page.code.to_i == 200
        cj = page.mech.agent.cookie_jar.store
        index = cj.count
        for i in 0...index
          index = i if cj.to_a[i].domain == 'aiesec.org'
        end
        if index != cj.count
          params = cj.to_a[index].value
          data = JSON.parse(URI.decode(params))
          @token = data["token"]["access_token"]
          @expiration_time = cj.to_a[index].created_at
          @max_age = data["token"]["max_age"]
          true
        end
      end
    end
  end
end
