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
        'teste-di-data-do-accepted': parse_date(application.accepted_at)
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

    def update_application_podio_status(application)
      check_podio
      attrs = {'fields': {
        'status-expa': map_status_prep(application.status.to_sym)
      }}
      item = Podio::Item.update(application.podio_id, attrs)
      item
    end

    def update_application(application)
      application.update_attributes(podio_sent: true, podio_sent_at: Time.now)
    end

    def update_application_podio_id(application)
      application.update_attributes(podio_id: podio_application_id(application.expa_id))
    end

    def podio_application_id(expa_id)
      check_podio
      Podio::Item.find_by_filter_values(
        ENV['PODIO_APP_OGX_PREP'],
        'expa-application-id': expa_id.to_s
      ).all.first.item_id
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
        'epid': application.expa_ep_id.to_s,
        status: status_to_podio(application.status),
        email: [
          {
            'type': 'home',
            value: application.exchange_participant.email
          }
        ],
        # 'data-de-nascimento': parse_date(application.exchange_participant.birthdate),
        'data-do-applied': parse_date(application.applied_at),
        'data-do-accepted': parse_date(application.accepted_at),
        'data-do-approved': parse_date(application.approved_at),
        'data-do-break-approval': parse_date(application.break_approved_at),
        'opportunity-name': application.opportunity_name,
        'expa-opportunity-id': application.tnid.to_s,
        'host-lc': application&.host_lc&.podio_id,
        'home-lc': application&.home_lc&.podio_id,
        'home-mc': application&.home_mc&.podio_id,
        'background-academico-do-ep': application&.exchange_participant&.academic_backgrounds,
        'background-da-vaga': application&.academic_backgrounds,
        'aplicante-qualificado': map_aplicante_qualificado(application),
        "celular": [
          {
            'type': 'mobile',
            value: application.exchange_participant.cellphone
          }
        ],
        'sdg-de-interesse': application.sdg_goal_index
      }
      # rubocop:enable Metrics/LineLength

      params = cut_icx_params_by_program(params, application)

      Raven.extra_context podio_params: params.to_json
      if application.podio_id.nil?
        app_id = PODIO_APPLICATION[application.product.to_sym]
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
        completed: 4,
        other_status: 6
      }
      mapper[status]
    end

    def map_status_prep(status)
      mapper = {
        realized: 2,
        finished: 3,
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
      return if !application&.home_mc&.podio_id.nil? || application.home_mc.nil?

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
      return if !application&.home_lc&.podio_id.nil? || application.home_lc.nil?
      items = Podio::Item.find_by_filter_values(
        '22140666',
        'title': application.home_lc.name
      )
      if items.count == 0
        raise "Raise couldn't find LCs Abroad for ICX Applications #{application&.home_lc&.attributes&.to_json}/#{application&.home_mc&.attributes&.to_json}"
      end
      if items.count > 1
        raise "Found more than one LCs Abroad for ICX Applications #{application&.home_lc&.attributes&.to_json}/#{application&.home_mc&.attributes&.to_json}"
      end
      application.home_lc.update_attributes(podio_id: items.all[0].item_id)
    end
  end

  def self.delete_icx_application(id)
    delete_item(id)
  end

  private

  def self.map_aplicante_qualificado(application)
    # code here
    (APLICANTE_QUALIFICADO_RULE.include? application.home_mc.name) ? 1 : 2
  end

  def self.cut_icx_params_by_program(params, application)
    to_cut = {
      'aplicante-qualificado': [:ge, :gv],
      'sdg-de-interesse': [:ge, :gt],
      'background-academico-do-ep': [:gv],
      'background-da-vaga': [:gv]
    }
    to_cut.each do |key, value|
      params = params.except(key) if value.include? application.product.to_sym
    end
    params
  end
end

PODIO_APPLICATION = {
  'ge': 22_140_491,
  'gv': 22_281_486,
  'gt': 22_282_262
}.freeze

APLICANTE_QUALIFICADO_RULE = [
  'Argentina', 'Austria', 'Belgium', 'Bolivia', 'Canada', 'Chile', 'Colombia',
  'Denmark', 'Ecuador', 'Spain', 'Finland', 'France', 'Germany',
  'Guatemala', 'Hungary', 'Ireland', 'Mexico', 'Morocco', 'Norway',
  'Panama', 'Paraguay', 'Peru', 'Poland', 'Portugal', 'Serbia', 'Sweden',
  'Switzerland', 'Tunisia', 'Turkey', 'Ukraine', 'Uruguay'
].freeze