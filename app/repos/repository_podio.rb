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
        status: status_to_podio(application.status),
        email: [
          {
            'type': 'home',
            value: application.exchange_participant.email
          }
        ],
        'data-de-nascimento': parse_date(application.exchange_participant.birthdate),
        'data-do-applied': parse_date(application.applied_at),
        'data-do-accepted': parse_date(application.accepted_at),
        'data-do-approved': parse_date(application.approved_at),
        'data-do-break-approval': parse_date(application.break_approved_at),
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

    def parse_date(date)
      date.strftime('%Y-%m-%d %H:%M:%S')
    end
  end

  def self.delete_icx_application(id)
    delete_item(id)
  end
end

