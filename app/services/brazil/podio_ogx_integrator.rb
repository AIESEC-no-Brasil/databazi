module Brazil
  class PodioOgxIntegrator
    def self.call(params)
      new(params).call
    end

    attr_accessor :status
    attr_reader :params, :exchange_participant

    def initialize(params)
      @params = params
      @exchange_participant = ExchangeParticipant.find_by(id: params['exchange_participant_id'])
      @status = false
    end

    def call
      Shoryuken.logger.info("=>SQS PARAMS:\n=>#{@params}\n=>SQS PARAMS END")

      # params gets initialized with the minimum amount of information which is known to always be existent
      podio_params = {
        'data-inscricao' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
        'title' => @params['fullname'],
        'email' => [{ 'type' => 'home', 'value' => @params['email'] }],
        'telefone' => [{ 'type' => 'home', 'value' => @params['cellphone'] }],
        'data-de-nascimento' => {
          start: Date.parse(@params['birthdate'].to_s).strftime('%Y-%m-%d %H:%M:%S')
        }
      }

      # then for each optional_key we check wether it's available on the incoming @params and assign it to params
      optional_keys.each { |k,v| @params[v[0]].present? ? podio_params.store(k, normalize_data(@params[v[0]], v[1])) : next }

      campaign_tag = @params.delete('utm_campaign')

      podio_id = RepositoryPodio.create_ep(ENV['PODIO_APP_LEADS_OGX'], podio_params).item_id

      create_campaign_tag(campaign_tag, podio_id) if campaign_tag

      @status = update_podio_id(podio_id)

      @status
    end

    private

    def create_campaign_tag(campaign_tag, podio_id)
      return false unless podio_id

      Podio::Tag.create('item', podio_id, [campaign_tag])
    end

    def update_podio_id(podio_id)
      return false unless podio_id

      @exchange_participant.update_attribute(:podio_id, podio_id)
    end

    # on optional_keys we have the translations to be made following the given format:
    # optional_keys = { 'podio-external-id': ['corresponding_databazi_key', ('data_manipulation_method' | nil)], ... }
    def optional_keys
      {
        'tag-origem-2': ['utm_source', 'utm_source_to_podio'],
        'cl-marcado-no-expa-nao-conta-expansao-ainda': ['local_committee', nil],
        'nivel-de-ingles': ['english_level', 'language_level_to_podio'],
        'curso': ['college_course', 'id_to_podio'],
        'sub-produto': ['experience', nil],
        'gostaria-de-ser-contactado-por-celular-2': ['cellphone_contactable', 'cellphone_contactable_option'],
        'produto': ['program', 'program_to_podio']
      }
    end

    # if no normalization method is supplied, simply return is value, otherwise build and eval "<method>(<value>)"
    def normalize_data(value, method)
      return value unless method

      if value.is_a? String
        eval("#{method}(\"#{value}\")")
      else
        eval("#{method}(#{value})")
      end
    end

    def program_to_podio(program)
      programmes = { gv: 1, ge: 2, gt: 3 }

      programmes[program.to_sym]
    end

    def id_to_podio(incoming)
      incoming.to_i
    end

    def language_level_to_podio(level)
      return 5 if level.zero?

      level
    end

    def utm_source_to_podio(db_source)
      podio_domains = {
        'rdstation': 1,
        'google': 2,
        'facebook': 3,
        'facebook-ads': 11,
        'instagram': 4,
        'twitter': 5,
        'twitter-ads': 12,
        'linkedin': 6,
        'linkedin-ads': 13,
        'youtube': 14,
        'site': 7,
        'blog': 8,
        'offline': 9,
        'outros': 10
      }

      podio_domain = podio_domains[db_source.downcase.to_sym]

      return podio_domains[:outros] unless podio_domain

      podio_domain
    end

    def utm_medium_to_podio(db_medium)
      podio_domains = {
        'banner': 19,
        'banner-home': 1,
        'pop-up': 10,
        'post-form': 12,
        'imagem': 7,
        'interacao': 20,
        'post-blog': 11,
        'post-link': 13,
        'stories': 15,
        'video': 17,
        'lead-ads': 9,
        'cpc': 4,
        'display': 5,
        'search': 14,
        'imagem-unica': 21,
        'cartaz': 3,
        'evento': 22,
        'indicacao': 8,
        'outro': 18,
        'panfleto': 23,
        'email': 6,
        'bumper': 2,
        'trueview': 16
      }

      podio_domain = podio_domains[db_medium.downcase.to_sym]

      return podio_domains[:outro] unless podio_domain

      podio_domain
    end

    def scholarity_name(index)
      ExchangeParticipant.brazilian_scholarity(ExchangeParticipant::BRAZILIAN_SCHOLARITY[index])
    end

    def cellphone_contactable_option(value)
      value ? 1 : 2
    end
  end
end
