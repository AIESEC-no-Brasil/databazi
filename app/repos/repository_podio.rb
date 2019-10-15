require "#{Rails.root}/app/repos/chat_logger"

class RepositoryPodio
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
        'status-expa': map_status(application.exchange_participant.status.to_sym)
      }}
      attrs[:fields]['teste-di-data-do-applied'] = parse_date(application.applied_at) if application.applied_at
      attrs[:fields]['teste-di-data-do-accepted'] = parse_date(application.accepted_at) if application.accepted_at
      attrs[:fields]['op-id-1'] = application.tnid.to_s if application.tnid
      if application.product == 'gv'
        attrs[:fields]['di-ep-id'] = application.exchange_participant.expa_id.to_s if application.exchange_participant.expa_id
      else
        attrs[:fields]['di-ep-id-2'] = application.exchange_participant.expa_id.to_s if application.exchange_participant.expa_id
      end
      item = Podio::Item.update(id, attrs)
      item
    end

    def send_ogx_application(id, application, approved_sync_count)
      check_podio

      attrs = {'fields': {
        "data-do-approved-#{approved_sync_count}": parse_date(application.approved_at),
        "op-id-#{approved_sync_count}": application.tnid.to_s,
        "produto-apd-#{approved_sync_count}": product_index(application)
      }}

      program = application&.exchange_participant&.registerable_type

      if program == 'GeParticipant' && approved_sync_count == 1
        attrs[:fields]["expa-application-id-#{approved_sync_count}-3"] = application.expa_id.to_s
      else
        attrs[:fields]["expa-application-id-#{approved_sync_count}"] = application.expa_id.to_s
      end


      item = Podio::Item.update(id, attrs)

      if item
        update_ogx_approved_sync_count(application.exchange_participant)
        define_ogx_application_as_sent(application)
      end

      item
    end

    def update_ogx_approved_sync_count(exchange_participant)
      exchange_participant.update_attributes(approved_sync_count: exchange_participant.reload.approved_sync_count + 1)
      exchange_participant.reload
    end

    def prep_valid_status_inclusion?(application)
      application.status.to_sym.in?(Expa::Application::PREP_STATUS) || application.status.to_sym.in?(Expa::Application::PREP_BROKEN_STATUS)
    end

    def update_ogx_application_prep(application)
      check_podio
      update_ogx_application_podio_id(application) unless application.podio_id

      if application.status.to_sym.in?(Expa::Application::PREP_BROKEN_STATUS)
        attrs = {'fields': {
          'status-da-quebra': map_status_prep_broken(application.status.to_sym)
        }}
      else
        attrs = {'fields': {
          'status-expa': map_ogx_status_prep(application.status.to_sym)
        }}
      end

      attrs[:fields]['expa-data-de-re'] = parse_date(application.realized_at) if application.realized_at
      attrs[:fields]['expa-data-de-fin'] = parse_date(application.completed_at) if application.completed_at

      attrs[:fields] = attrs[:fields].merge(map_standards(application.standards)) if application.standards

      item = Podio::Item.update(application.podio_id, attrs)
      item
    end

    def update_icx_application_prep(application)
      check_podio

      status = check_status(application.status, application.completed_at)

      update_icx_application_prep_podio_id(application) unless application.prep_podio_id
      attrs = {'fields': {
        'status-expa': map_icx_status_prep(status.to_sym)
      }}

      attrs[:fields]['expa-data-de-re'] = parse_date(application.realized_at) if application.realized_at
      attrs[:fields]['expa-data-de-fin'] = parse_date(application.completed_at) if application.completed_at

      attrs[:fields] = attrs[:fields].merge(map_standards(application.standards)) if application.standards

      item = Podio::Item.update(application.prep_podio_id, attrs)
      item
    end

    def map_standards(standards)
      podio_standards_fields = {}
      standards.each do |standard|
        standard_data = standard['data'] || standard['table']
        podio_key = map_standard_constant_to_podio(standard_data['constant_name'])
        podio_value = map_standard_option_to_podio(standard_data['option'])
        podio_standards_fields[podio_key] = podio_value if podio_key
      end
      podio_standards_fields
    end

    def map_standard_constant_to_podio(constant)
      map_constant = {
        'Personal goal setting': '1-personal-goal-setting',
        'Outgoing Preparation': '2-outgoing-preparation',
        'Expectation setting': '3-expectation-setting',
        'Incoming Preparation': '4-incoming-preparation',
        'Development Spaces with Opportunity Provider': '5-dev-spaces-with-opportunity-provider',
        'Debrief with AIESEC home': '6-debrief-with-aiesec-home',
        'Visa and work permit': '7-visa-work-permit',
        'Arrival pickup': '8-arrival-pick-up',
        'Departure support': '9-departure-support',
        'Job description': '10-job-description',
        'Duration': '11-duration',
        'Working hours': '12-working-hours',
        'First day of work': '13-first-day-of-work',
        'Insurance': '14-insurance',
        'Accommodation': '15-accommodation',
        'Basic living costs': '16-basic-living-costs'
      }
      map_constant[constant.to_sym]
    end

    def map_standard_option_to_podio(option)
      return 1 unless option #default is 'not filled'

      map_option = {
        'true': 2,
        'false': 3,
        'not needed': 4
      }
      map_option[option.to_sym] || 1 #default is 'not filled'
    end

    def define_ogx_application_as_sent(application)
      application.update_attributes(podio_sent: true, podio_sent_at: Time.now)
    end

    def update_ogx_application_podio_id(application)
      application.update_attributes(podio_id: get_podio_application_id(application.expa_id, ENV['PODIO_APP_OGX_PREP']))
    end

    def update_icx_application_prep_podio_id(application)
      app_area = ENV["PODIO_APP_ICX_I#{application.product_upcase}_PREP"]
      application.update_attributes(
        prep_podio_id: get_podio_application_id(application.expa_id, app_area)
      )
    end

    def get_podio_application_id(expa_id, app_area)
      check_podio
      Podio::Item.find_by_filter_values(
        app_area,
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
        status: icx_status_to_podio(application.status),
        email: [
          {
            'type': 'home',
            value: application.exchange_participant.email
          }
        ],
        #'data-de-nascimento': parse_date(application.exchange_participant.birthdate),
        'data-do-applied': parse_date(application.applied_at),
        'data-do-accepted': application.accepted_at ? parse_date(application.accepted_at) : nil,
        'data-do-approved': parse_date(application.approved_at),
        'opportunity-name': application.opportunity_name,
        'opportunity-start-date': parse_date(application.opportunity_start_date),
        'expa-opportunity-id': application.tnid.to_s,
        'host-lc': application&.host_lc&.podio_id,
        'home-lc': application&.home_lc&.podio_id,
        'home-mc': application&.home_mc&.podio_id,
        'background-academico-do-ep': application&.exchange_participant&.academic_backgrounds,
        'background-da-vaga': application&.academic_backgrounds,
        "celular": [
          {
            'type': 'mobile',
            value: application.exchange_participant.cellphone ? application.exchange_participant.cellphone[0...50] : nil #maximum of 50 characters (podio limit)
          }
        ],
        'sdg-de-interesse': application.sdg_goal_index,
        'expa-application-id': application.expa_id.to_s
      }

      params['aplicante-qualificado'] = map_aplicante_qualificado(application) if application.home_mc&.name

      params['data-do-break-approval'] = application.break_approved_at ? parse_date(application.break_approved_at) : nil

      params['quero-ser-contactado-por-telefone'] = application&.exchange_participant&.cellphone_contactable ? 1 : 2 #1 = Yes, 2 = No

      params['da-onde-veio-este-ep'] = application.from_impact ? 2 : 1 #1 = YOP, 2 = Impact Brazil

      params['opportunity-date-opened'] = parse_date(application.opportunity_date) unless application.product.to_sym == :gv

      params['projeto'] = BrazilIcxProject.call(application.opportunity_name) if application.product == 'gv'


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

      begin
        update_icx_application_prep(application) if prep_valid_status_inclusion?(application)
      rescue => exception
        Raven.capture_message "[ICX I#{application.product_upcase} Prep]Error when updating prep data",
        extra: {
          application: application.to_json,
          exception: exception
        }
        application.update_attribute(:prep_podio_sync_error, true)
      end
    end

    private

    def check_status(original_status, completed_at)
      return 'finished' if original_status == 'realized' && completed_at <= Time.now

      original_status
    end

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

    def map_ogx_status_prep(status)
      mapper = {
        realized: 2,
        finished: 3,
        completed: 4
      }
      mapper[status]
    end

    def map_icx_status_prep(status)
      mapper = {
        realized: 2,
        finished: 3,
        completed: 4,
        realization_broken: 5
      }
      mapper[status]
    end

    def map_status_prep_broken(status)
      mapper = {
        approval_broken: 1,
        realization_broken: 2
      }
      mapper[status]
    end

    def icx_status_to_podio(status)
      mapping = {
        open: 1,
        applied: 1,
        matched: 8, #accepted
        accepted: 2, #lda preenchido
        approved: 3,
        realized: 3, #this status is after 'approved' and it'll only be be used in ICX PREP, in this stage it must stop on 'approved' status
        completed: 3, #this status is after 'approved' and it'll only be be used in ICX PREP, in this stage it must stop on 'approved' status
        realization_broken: 3, #this status is after 'approved' and it'll only be be used in ICX PREP, in this stage it must stop on 'approved' status
        break_approved: 9,
        approval_broken: 9,
        rejected: 5,
        withdrawn: 7
      }
      podio_status = mapping[status.to_sym] || 6 # default other
      Repos::ChatLogger.notify_on_client_channel("[ICX to Podio]Status não mapeado: #{status}") if podio_status == 6
      podio_status
    end

    def parse_date(date)
      return nil if date.nil?
      date.strftime('%Y-%m-%d %H:%M:%S')
    end

    def check_podio
      return unless Podio.client.nil?

      setup_podio
      authenticate_podio
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
      mc_podio_id = nil
      if items.count.zero?
        params = {
          titulo: application&.home_mc&.name,
          'expa-id': application&.home_mc&.expa_id
        }
        mc = Podio::Item.create('22140562', fields: params)
        mc_podio_id = mc.item_id
      else
        mc_podio_id = items.all[0].item_id
      end

      application.home_mc.update_attributes(podio_id: mc_podio_id)
    end

    def sync_home_lc(application)
      return if !application&.home_lc&.podio_id.nil? || application.home_lc.nil?

      items = Podio::Item.find_by_filter_values(
        '22140666',
        'title': application.home_lc.name
      )
      lc_podio_id = nil
      if items.count.zero?
        params = {
          title: application&.home_lc&.name,
          mc: application&.home_mc&.podio_id
        }
        lc = Podio::Item.create('22140666', fields: params)
        lc_podio_id = lc.item_id
      else
        lc_podio_id = items.all[0].item_id
      end

      application.home_lc.update_attributes(podio_id: lc_podio_id)
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
      params = params.except(key.to_s) if value.include?(application.product.to_sym)
      params = params.except(key.to_sym) if value.include?(application.product.to_sym)
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
