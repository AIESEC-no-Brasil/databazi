module Brazil
  class PodioOgxPrepIntegrator

    def self.call(params)
      new(params).call
    end

    attr_accessor :application

    def initialize(params)
      @application = params
    end

    def call
      podio_params = {}

      podio_params.store('nome-do-ep', @application.try(:exchange_participant).try(:podio_id)

      prep_keys.each { |k,v| @application.try(v[0].to_sym) ? podio_params.store(k.to_s, normalize_data(@application.send(v[0].to_sym), v[1])) : next }

      podio_id = RepositoryPodio.create_ep(ENV['PODIO_APP_PREP_OGX'], podio_params.stringify_keys).item_id

      @status = update_podio_id(podio_id)

      @status
    end

    private

    def approved_at_to_podio(approved_at)
      { start: Date.parse(approved_at).strftime('%Y-%m-%d %H:%M:%S') }
    end

    def cellphone_to_podio(cellphone)
      [{ 'type' => 'home', 'value' => cellphone }]
    end

    def email_to_podio(email)
      [{ 'type' => 'home', 'value' => email }]
    end

    def exchange_participant_expa_id_to_podio(exchange_participant_expa_id)
      exchange_participant_expa_id.to_s
    end

    def expa_id_to_podio(expa_id)
      expa_id.to_s
    end

    def normalize_data(value, method)
      return value unless method

      if (value.is_a?(String) || value.is_a?(ActiveSupport::TimeWithZone))
        eval("#{method}(\"#{value}\")")
      else
        eval("#{method}(#{value})")
      end
    end

    def prep_keys
      {
        'comite-de-origem': ['exchange_participant_local_committee_podio_id', nil],
        'ep-id': ['exchange_participant_expa_id', 'exchange_participant_expa_id_to_podio'],
        'email': ['exchange_participant_email', 'email_to_podio'],
        'telefone': ['exchange_participant_cellphone', 'cellphone_to_podio'],
        'expa-application-id': ['expa_id', 'expa_id_to_podio'],
        'produto': ['product', 'product_to_podio'],
        'status-expa': ['status', 'status_to_podio'],
        'op-id': ['tnid', 'tnid_to_podio'],
        'expa-data-do-apd': ['approved_at', 'approved_at_to_podio']
      }
    end

    def product_to_podio(product)
      translation = { gv: 1, ge: 2, gt: 3 }

      translation[product.to_sym]
    end

    def status_to_podio(status)
      translation = { approved: 1, realized: 2, finished: 3, completed: 4, realization_broken: 5, withdrawn: 6 }

      translation[status.to_sym]
    end

    def tnid_to_podio(tnid)
      tnid.to_s
    end

    def update_podio_id(podio_id)
      return false unless podio_id

      @application.update_attribute(:prep_podio_id, podio_id)
    end
  end
end
