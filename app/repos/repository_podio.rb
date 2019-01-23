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
      # rubocop:disable Metrics/LineLength
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
        'background-academico': application.academic_experience,
        'opportunity-name': application.opportunity_name,
        'op-id': application.opportunity_expa_id,
        'host-lc': application&.host_lc&.podio_id,
        'home-lc': application&.home_lc&.podio_id,
        'home-mc': 1_023_733_737, # Fixed to Brasil
        "celular": [
          {
            'type': 'mobile',
            value: application.exchange_participant.cellphone
          }
        ],
        'sdg-de-interesse': application.sdg_goal_index
      }
      # rubocop:enable Metrics/LineLength
      case application.exchange_participant.registerable
      when GtParticipant
        ep_type = ENV['PODIO_APP_ICX_APPLICATIONS_GT']
      when GvParticipant
        ep_type = ENV['PODIO_APP_ICX_APPLICATIONS_GV']
      when GeParticipant
        ep_type = ENV['PODIO_APP_ICX_APPLICATIONS_GE']
      else
        raise "Application without ep with registerable ap.id #{application.id}"
      end
      Podio::Item.create(ep_type, fields: params)
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
      mapping[status.to_sym] || 6 # default other
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
      return nil if date.nil?
      date.strftime('%Y-%m-%d %H:%M:%S')
    end
  end

  def self.delete_icx_application(id)
    delete_item(id)
  end
end

