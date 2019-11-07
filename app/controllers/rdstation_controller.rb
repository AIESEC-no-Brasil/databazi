class RdstationController < ApplicationController
  def new_lead

    raise 'missing email' if !params['email'].presence()

    rdstation_authentication = RDStation::Authentication.new(ENV['RDSTATION_CLIENT_ID'], ENV['RDSTATION_CLIENT_SECRET'])
    rdstation_authentication.auth_url(ENV['RDSTATION_REDIRECT_URL'])

    access_token = rdstation_authentication.update_access_token(ENV['RDSTATION_REFRESH_TOKEN'])['access_token']

    #p access_token

    client = RDStation::Client.new(access_token: access_token)

    client.contacts.upsert('email', params[:email], params['rdstation'].except('email'))

    render json: { status: 200, message: 'Success' }
  end
end
