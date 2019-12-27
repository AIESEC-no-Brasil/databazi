class ExchangeParticipantsController < ApplicationController
  require 'net/http'
  require 'uri'

  def validate_email
    if check_email_existence(params[:email])
      render json: { email_exists: true }
    else
      render json: { email_exists: false }
    end
  end

  private

  def check_email_existence(email)
    exchange_participant = find_exchange_participant(email)

    if exchange_participant
      RepositoryPodio.init
      Podio::Tag.create('item', exchange_participant&.podio_id, ['retentativa-de-cadastro'])

      return true
    end

    false
  end

  def find_exchange_participant(email)
    ExchangeParticipant.find_by(email: email)
  end
end
