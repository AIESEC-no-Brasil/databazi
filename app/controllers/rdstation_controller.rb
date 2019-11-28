class RdstationController < ApplicationController
  def new_lead

    raise 'missing email' if !params['email'].presence()

    integrator = RdstationIntegration.new

    integrator.upsert_contact(params[:email], params['rdstation'].except('email'))
    integrator.create_conversion_event(params['rdstation']['email'], params['rdstation']['cf_conversion_events']) if params['rdstation']['cf_conversion_events'].presence()
    
    render json: { status: 200, message: 'Success' }
  end
end
