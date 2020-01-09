require "#{Rails.root}/lib/expa_api"

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
    else
      res = EXPAAPI::Client.query(
        ExistsQuery,
        variables: {
          email: email
        }
      ).data.check_person_present

      if res
        programme = nil

        if res.programmes.any?
          res.programmes.each do |programme|
            programme = programme[:short_name_display] if programme[:short_name_display].in?(%w[GV GE GT])
          end
        end

        programme ||= 'GV'

        exchange_participant = ExchangeParticipant.where(expa_id: res.id).first_or_initialize(
          expa_id: res.id,
          fullname: res.full_name,
          birthdate: res.try(:dob),
          email: res.email,
          local_committee_id: LocalCommittee.where('name ilike ?', res.home_lc.name).first.try(:id),
          program: programme.downcase.to_sym,
          status: res.status
        )

        exchange_participant.save(validate: false)
      end

      ExpaToPodioWorker.perform_async({ 'exchange_participant_id' => exchange_participant.id })

      return true
    end

    false
  end

  def find_exchange_participant(email)
    ExchangeParticipant.find_by(email: email)
  end
end
