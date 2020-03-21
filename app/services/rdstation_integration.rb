class RdstationIntegration
  include HTTParty

  def initialize
    @api_base_url = 'https://api.rd.services/platform'
    @access_token = rdstation_authentication_token
    @client = RDStation::Client.new(access_token: @access_token)
  end

  def fields
    @client.fields.all
  end

  def field_exists?(field)
    fields.first[1].any? { |f| f['api_identifier'] == field }
  end

  def fetch_contact_by_email(email)
    begin
      @client.contacts.by_email(email)
    rescue => exception
      nil
    end
  end

  def update_lead_by_uuid(uuid, contact_info = {})
    @client.contacts.update(uuid, contact_info)
  end

  # Fetchs a contact's funnel given its uuid, returning its lifecycle_stage and opportunity status
  def fetch_funnel(uuid)
    res = HTTParty.get(funnel_endpoint(uuid), headers: funnel_headers)

    { lifecycle_stage: res["lifecycle_stage"], opportunity: res["opportunity"] }
  end

  # Updates a contact's funnel lifecycle_stage (string) and opportunity (boolean) given its uuid
  # lifecycle_stage valid values are: "Lead", "Qualified Lead", and "Client"
  # expected payload: { "lifecycle_stage": "Lead", "opportunity": true }
  def update_funnel(uuid, data)
    res = HTTParty.put(funnel_endpoint(uuid), headers: funnel_headers, body: data.to_json)

    { lifecycle_stage: res["lifecycle_stage"], opportunity: res["opportunity"] }
  end

  def create_conversion_event(email, conversion_event)
    @client.events.create({
      'event_type' => 'CONVERSION',
      'event_family' => 'CDP',
      'payload' => {
        'conversion_identifier'=> conversion_event,
        'email'=> email
      }
    })
  end

  def upsert_contact(email, payload)
    @client.contacts.upsert('email', email, payload)
  end

  private

  def funnel_endpoint(uuid)
    "#{@api_base_url}/contacts/#{uuid}/funnels/default"
  end

  def funnel_headers
    { 'Authorization' => "Bearer #{@access_token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  def rdstation_authentication_token
    rdstation_authentication = RDStation::Authentication.new(ENV['RDSTATION_CLIENT_ID'], ENV['RDSTATION_CLIENT_SECRET'])
    rdstation_authentication.auth_url(ENV['RDSTATION_REDIRECT_URL'])

    rdstation_authentication.update_access_token(ENV['RDSTATION_REFRESH_TOKEN'])['access_token']
  end
  
end