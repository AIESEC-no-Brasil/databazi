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
    exchange_participant
    url = 'https://auth.aiesec.org/users/sign_in'

    agent = Mechanize.new {|a| a.ssl_version, a.verify_mode = 'TLSv1',OpenSSL::SSL::VERIFY_NONE}
    page = agent.get(url)

    auth_form = page.forms[1]
    auth_form.field_with(:name => 'user[email]').value = exchange_participant.email
    auth_form.field_with(:name => 'user[first_name]').value = exchange_participant.first_name
    auth_form.field_with(:name => 'user[last_name]').value = exchange_participant.last_name
    auth_form.field_with(:name => 'user[password]').value = exchange_participant.decrypted_password
    auth_form.field_with(:name => 'user[country]').value = 'Brazil'
    auth_form.field_with(:name => 'user[mc]').value = '1606'
    # case params["interested_program"]
    #   when 'GCDP', 'GV'
    #     auth_form.field_with(:name => 'user[lc]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]
    #     auth_form.field_with(:name => 'user[lc_input]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]
    #   when 'GIP', 'GT'
    #     auth_form.field_with(:name => 'user[lc]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogt[params["lc"].to_i]]['ids'][0]
    #     auth_form.field_with(:name => 'user[lc_input]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]
    #   when 'GE'
    #     auth_form.field_with(:name => 'user[lc]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_oge[params["lc"].to_i]]['ids'][0]
    #     auth_form.field_with(:name => 'user[lc_input]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]
    #   else
    #     auth_form.field_with(:name => 'user[lc]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]
    #     auth_form.field_with(:name => 'user[lc_input]').value = DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]
    # end

    # Shoryuken.logger.info("============================")
    # Shoryuken.logger.info("#{params}")
    # Shoryuken.logger.info("#{params["lc"].to_i}")
    # Shoryuken.logger.info("LC: #{DigitalTransformation.hash_entities_podio_expa[DigitalTransformation.entities_ogcdp[params["lc"].to_i]]['ids'][0]}")
    # Shoryuken.logger.info("user[lc]: #{auth_form.field_with(:name => 'user[lc]').value}")
    # Shoryuken.logger.info("user[lc_input]: #{auth_form.field_with(:name => 'user[lc_input]')}")
    # Shoryuken.logger.info("============================")

    # page = agent.submit(auth_form, auth_form.buttons.first)

    # page.code.to_i == 200 && !check_page_for_errors(page)
  end

  def check_page_for_errors(page)
    page.search('span.red_icon')
  end
end
