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
      ).try(:data).try(:check_person_present)

      if res
        programme = nil

        if res.programmes.any?
          res.programmes.each do |program|
            programme = program.short_name_display if (%w[GV GE GT]).include?(program.short_name_display)
          end
        end

        programme ||= 'GV'

        exchange_participant = ExchangeParticipant.where(expa_id: res.id).first_or_initialize(
          expa_id: res.id,
          fullname: res.full_name,
          birthdate: res.try(:dob),
          email: email,
          local_committee_id: LocalCommittee.where('name ilike ?', res.home_lc.name).first.try(:id),
          program: programme.downcase.to_sym,
          status: res.status,
          origin: :expa
        )

        exchange_participant.save(validate: false)

        @status = Brazil::PodioOgxIntegrator.call(assemble_message(exchange_participant))

        return @status
      end
    end

    false
  end

  def assemble_message(exchange_participant)
    message = {
      'exchange_participant_id' => exchange_participant.id,
      'status' => exchange_participant.status_to_podio,
      'expa_id' => exchange_participant.expa_id,
      'fullname' => exchange_participant.fullname,
      'birthdate' => exchange_participant.birthdate,
      'email' => exchange_participant.email,
      'local_committee' => exchange_participant&.local_committee&.podio_id,
      'program' => exchange_participant.program
    }

    databazi_keys.each { |k| if value = exchange_participant.try(k.to_sym); message.store(trim_key(k), normalize_value(value)); end }

    message
  end

  def trim_key(key)
    key.gsub(/_podio_id$/, '')
  end

  def normalize_value(value)
    return value.to_s if (value.instance_of? Date)

    value
  end

  def find_exchange_participant(email)
    ExchangeParticipant.find_by(email: email)
  end
end
