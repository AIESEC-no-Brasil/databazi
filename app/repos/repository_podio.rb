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
        'teste-di-data-do-approved': parse_date(application.approved_at),
        'teste-di-data-do-break-approval': parse_date(application.break_approved_at)
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

      sync_icx_country(application)
      sync_home_lc(application)
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
        'opportunity-name': application.opportunity_name,
        'op-id': application.opportunity_expa_id,
        'host-lc': application&.host_lc&.podio_id,
        'home-lc': application&.home_lc&.podio_id,
        'home-mc': application&.home_mc&.podio_id,
        'background-academico-do-ep': application&.exchange_participant&.academic_backgrounds,
        'background-da-vaga': application&.academic_backgrounds,
        "celular": [
          {
            'type': 'mobile',
            value: application.exchange_participant.cellphone
          }
        ],
        'sdg-de-interesse': application.sdg_goal_index
      }
      # rubocop:enable Metrics/LineLength

      if application.podio_id.nil?
        type = application.exchange_participant.registerable_type
        app_id = PODIO_APPLICATION[type.to_sym]
        podio_item = Podio::Item.create(app_id, fields: params)
        application.update_attributes(
          podio_last_sync: Time.now,
          podio_id: podio_item.item_id
        )
      else
        Podio::Item.update(application.podio_id, fields: params)
        application.update_attributes(
          podio_last_sync: Time.now
        )
      end
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

    def parse_date(date)
      return nil if date.nil?
      date.strftime('%Y-%m-%d %H:%M:%S')
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

    def sync_icx_country(application)
      if !application&.home_mc&.podio_id.nil? || application.home_mc.nil?
        return
      end

      items = Podio::Item.find_by_filter_values(
        '22140562',
        'expa-id': {
          from: application.home_mc.expa_id,
          to: application.home_mc.expa_id
        }
      )
      if items.count != 1
        raise "Raise couldn't find MC in ICX Paises #{application.home_mc.id}/#{application.home_mc.name}"
      end

      application.home_mc.update_attributes(podio_id: items.all[0].item_id)
    end

    def sync_home_lc(application)
      if !application&.home_lc&.podio_id.nil? || application.home_lc.nil?
        return
      end
      items = Podio::Item.find_by_filter_values(
        '22140666',
        'title': application.home_lc.name
      )
      if items.count == 0
        raise "Raise couldn't find LCs Abroad for ICX Applications #{application.home_lc.expa_id}/#{application.home_lc.name}"
      end
      if items.count > 1
        raise "Found more than one LCs Abroad for ICX Applications #{application.home_lc.expa_id}/#{application.home_lc.name}"
      end
      application.home_lc.update_attributes(podio_id: items.all[0].item_id)
    end
  end

  def self.delete_icx_application(id)
    delete_item(id)
  end
end

PODIO_APPLICATION = {
  'GeParticipant': 22_140_491,
  'GvParticipant': 22_140_491,
  'GtParticipant': 22_140_491
}.freeze