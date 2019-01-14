class RepositoryPodio
  @@is_podio_initialized = false

  class << self
    def create_ep(application, params)
      check_podio
      Podio::Item.create(application, fields: params)
    end

    def delete_ep(id)
      delete_item(id)
    end

    def change_status(id, status)
      check_podio
      attrs = {'fields': {
        'status-expa': status
      }}
      item = Podio::Item.update(id, attrs)
      item
    end

    def get_item(id)
      check_podio
      Podio::Item.find(id)
    end

    # TODO: Code the Podio ICX application integration
    def save_icx_application(application)
      check_podio
      params = {
        title: application.exchange_participant.fullname,
        'ep-id': application.expa_ep_id,
        status: status_to_podio(application.status)
      }
      Podio::Item.create(ENV['PODIO_APP_ICX_APPLICATIONS'], fields: params)
    end

    private

    def status_to_podio(status)
      mapping = {
        open: 6,
        applied: 1,
        accepted: 2,
        approved: 3,
        break_approved: 4,
        rejected: 5,
      }
      mapping[status.to_sym]
    end

    def check_podio
      return if @@is_podio_initialized
      setup_podio
      authenticate_podio
      @@is_podio_initialized = true
    end

    def authenticate_podio
      Podio.client.authenticate_with_credentials(
        ENV['PODIO_USERNAME'],
        ENV['PODIO_PASSWORD']
      )
    end

    def setup_podio
      Podio.setup(
        api_key: ENV['PODIO_API_KEY'],
        api_secret: ENV['PODIO_API_SECRET']
      )
    end

    def delete_item(id)
      check_podio
      Podio::Item.delete(id)
    end
  end

  def self.delete_icx_application(id)
    delete_item(id)
  end
end

