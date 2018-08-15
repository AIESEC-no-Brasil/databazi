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
    find_exchange_participant(email) || bazicon_email_validation(email)
  end

  def find_exchange_participant(email)
    true if ExchangeParticipant.find_by(email: email)
  end

  def bazicon_email_validation(_email)
    # Uncomment method when
    # https://github.com/AIESEC-no-Brasil/Bazicon/pull/213
    # has been merged and deployed to production
    false
    # uri = URI.parse('http://bazicon.aiesec.org.br/' \
    #   "api/v1/expa_person?email=#{email}")

    # JSON.parse(Net::HTTP.get_response(uri).read_body)['email_exists']
  end
end
