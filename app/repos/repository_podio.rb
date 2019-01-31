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

    def change_status(id, application)
      check_podio
      attrs = {'fields': {
        'status-expa': map_status(application.exchange_participant.status.to_sym),
        'teste-di-data-do-applied': parse_date(application.applied_at),
        'teste-di-data-do-accepted': parse_date(application.accepted_at),
      }}
      item = Podio::Item.update(id, attrs)
      item
    end

    def send_application(id, application, approved_sync_count)
      check_podio

      attrs = {'fields': {
        "data-do-approved-#{approved_sync_count}": parse_date(application.approved_at),
        "link-da-vaga-#{approved_sync_count}-tnid-#{approved_sync_count}": embed_id(application),
        "produto-apd-#{approved_sync_count}": product_index(application),
        "expa-application-id-#{approved_sync_count}": application.expa_id.to_s
      }}

      item = Podio::Item.update(id, attrs)

      if item
        update_approved_sync_count(application.exchange_participant)
        update_application(application)
      end

      item
    end

    def update_approved_sync_count(exchange_participant)
      exchange_participant.update_attributes(approved_sync_count: exchange_participant.reload.approved_sync_count + 1)
      exchange_participant.reload
    end

    def update_application(application)
      application.update_attributes(podio_sent: true, podio_sent_at: Time.now)
    end

    def get_item(id)
      check_podio
      Podio::Item.find(id)
    end

    private

    def embed_id(application)
      Podio::Embed.create(application.opportunity_link).embed_id
    end

    def parse_date(date)
      return nil if date.nil?
      date.strftime('%Y-%m-%d %H:%M:%S')
    end

    def product_index(application)
      application.read_attribute_before_type_cast(:product) + 1
    end

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

