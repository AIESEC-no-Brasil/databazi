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
    find_exchange_participant(email)
  end

  def find_exchange_participant(email)
    true if ExchangeParticipant.find_by(email: email)
  end
end
