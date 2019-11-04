module Brazil
  class PodioOgxStatusUpdate

    def self.call(params)
      new(params).call
    end

    attr_reader :application
    attr_accessor :status

    def initialize(params)
      @application = params
      @status = false
    end

    def call
      res = update_application_on_podio

      @status = update_application_locally if res == 200

      @status
    end

    private

    def fields_to_update
      { 'status-expa': status_to_podio(@application.status) }
    end

    def update_application_locally
      @application.update_attribute(:podio_last_synched_status, @application.status)
    end

    def update_application_on_podio
      RepositoryPodio.update_fields(@application.prep_podio_id, fields_to_update)
    end

    def status_to_podio(status)
      translation = { approved: 1, realized: 2, finished: 3, completed: 4, realization_broken: 5, withdrawn: 6 }

      translation[status.to_sym]
    end
  end
end
