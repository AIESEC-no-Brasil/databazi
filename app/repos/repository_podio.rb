class RepositoryPodio
  @@is_podio_initialized = false

  class << self
    def create_ep(application, params)
      check_podio
      Podio::Item.create(application, fields: params)
    end

    def delete_ep(id)
      check_podio
      Podio::Item.delete(id)
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

    private

    def map_status(status)
      mapper = {
        open: 1,
        applied: 2,
        accepted: 3,
        approved_tn_manager: 4,
        approved_ep_manager: 4,
        approved: 4,
        break_approved: 5,
        rejected: 6,
        withdrawn: 6,
        realized: 4,
        approval_broken: 6,
        realization_broken: 5,
        matched: 4,
        completed: 4
      }
      mapper[status]
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
  end
end

