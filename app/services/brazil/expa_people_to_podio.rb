module Brazil
  class ExpaPeopleToPodio
    attr_reader :status

    def self.call(params = nil)
      new(params).call
    end

    def initialize(params = nil)
      @pending = params || pending_exchange_participants
      @status = false
    end

    def call
      @pending.each do |exchange_participant|
        @status = Brazil::PodioOgxIntegrator.call(assemble_message(exchange_participant))

        exchange_participant.update_attribute(:has_error, true) unless @status

        sleep 3
      end
    end

    private

    # based on given databazi_keys, assembles the message as `{ key => value }` based on given key existence (non-nil value) on exchange_participant
    def assemble_message(exchange_participant)
      message = {
        'exchange_participant_id' => exchange_participant.id,
        'status' => exchange_participant.status_to_podio
      }

      databazi_keys.each { |k| if value = exchange_participant.try(k.to_sym); message.store(trim_key(k), normalize_value(value)); end }

      message
    end

    # list of (databazi) keys expected to be synchronized with podio
    def databazi_keys
      %w[
        birthdate
        cellphone
        email
        expa_id
        fullname
        local_committee_podio_id
        origin
        program
      ]
    end

    # key trimming method so we match the expected identifiers established in Brazil::PodioOgxIntegrator#optional_keys
    def trim_key(key)
      key.gsub(/_podio_id$/, '')
    end

    def normalize_value(value)
      return value.to_s if (value.instance_of? Date)

      value
    end

    def pending_exchange_participants
      ExchangeParticipant.where(podio_id: nil)
                         .where(origin: :expa)
                         .order(created_at: :desc)
                         .limit(10)
    end
  end
end
