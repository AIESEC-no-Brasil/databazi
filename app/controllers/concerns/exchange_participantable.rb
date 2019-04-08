module ExchangeParticipantable
  extend ActiveSupport::Concern
  def create
    if exchange_participantable.save
      perform_on_workers
      update_rd_lead if ENV['COUNTRY'] == 'per'
      render json: { status: :success }
    else
      remove_campaign
      render json: {
        status: :failure,
        messages: exchange_participantable.errors.messages
      }
    end
  end

  private

  def perform_on_workers
    SendToPodioWorker.perform_async(ep_fields)
    SignUpWorker.perform_async(exchange_participantable.as_sqs)
  end

  def update_rd_lead
    puts exchange_participantable

    rdstation_authentication = RDStation::Authentication.new(ENV['RDSTATION_CLIENT_ID'], ENV['RDSTATION_CLIENT_SECRET'])
    rdstation_authentication.auth_url(ENV['RDSTATION_REDIRECT_URL'])

    access_token = rdstation_authentication.update_access_token(ENV['RDSTATION_REFRESH_TOKEN'])['access_token']

    contact = RDStation::Contacts.new(access_token)
    lead = contact.by_email(exchange_participantable.email)

    contact_info = {
      cf_persona: peruvian_exchange_reason(exchange_participantable.exchange_participant.exchange_reason, exchange_participantable.class.name),
      cf_referral: peruvian_referral_type(exchange_participantable.exchange_participant.referral_type)
    }

    contact.update(lead['uuid'], contact_info)
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

  def program_snake_case(program)
    program.underscore.downcase
  end

  def remove_campaign
    campaign.destroy
  end
end
