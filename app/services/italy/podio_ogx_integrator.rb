module Italy
  class PodioOgxIntegrator
    def self.call(params)
      new(params).call
    end

    attr_accessor :status
    attr_reader :params, :exchange_participant

    def initialize(params)
      @params = params
      @exchange_participant = ExchangeParticipant.find_by(id: params['exchange_participant_id'])
      
      puts @exchange_participant

      @status = false
    end

    def call    
      Shoryuken.logger.info("=>SQS PARAMS:\n=>#{@params}\n=>SQS PARAMS END")


      #'data-inscricao' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },

      # params gets initialized with the minimum amount of information which is known to always be existent
      podio_params = {        
        'title' => @exchange_participant.fullname,
        'email' => email_to_podio(@exchange_participant.email),
        'birthdate' => birthdate_to_podio(@exchange_participant.birthdate),
        'city' => @exchange_participant.city,
        'region' => @exchange_participant.department
      }      

      podio_params.store('cellphone', cellphone_to_podio(@exchange_participant.cellphone)) if @exchange_participant.cellphone_contactable

      podio_params.store('english-level', english_level_name(@exchange_participant.registerable.english_level)) if @exchange_participant.registerable.try(:english_level)

      podio_params.store('subproduct-of-interest', subproduct_of_interest_name(@exchange_participant.registerable.subproduct)) if @exchange_participant.registerable.try(:subproduct)

      podio_params.store('work-experience', work_experience_name(@exchange_participant.registerable.work_experience)) if @exchange_participant.registerable.try(:work_experience)

      podio_params.store('education-level', scholarity_name(@exchange_participant.scholarity)) if @exchange_participant.scholarity

      
      #TODO - missing "Product Registered to:" and "HOME LC" - create these field on Podio
      
      #TODO - missing university and referral (front-end it's not sending this yet)
      #TODO - missing Preferred Start Date - this is field it's not in the form doc (?)      
      #TODO - Form ID - find out what this is

      podio_id = RepositoryPodio.create_ep(ENV['PODIO_APP_LEADS_OGX'], podio_params).item_id      
      @status = update_podio_id(podio_id)      
      @status
    end

    private

    def english_level_name(english_level)
      {
        'none' => 'Non parla inglese',
        'basic' => 'Base',
        'intermediate' => 'Intermedio',
        'advanced' => 'Avanzato',
      }[english_level.to_s]
    end

    def subproduct_of_interest_name(subproduct)
      {
        'business_administration' => 'Business Administration',
        'marketing' => 'Marketing',
        'teaching' => 'Insegnamento',
        'other' => 'Altro',
      }[subproduct.to_s]
    end

    def work_experience_name(work_experience)
      p 'hmm'
      p work_experience
      {
        'none' => 'Non ho esperienza',
        'less_than_3_months' => 'Meno di 3 mesi',
        'more_than_3_months' => 'Più di 3 mesi',
        'more_than_6_months' => 'Più di 6 mesi',
        'more_than_a_year' => 'Più di un anno"'
      }[work_experience.to_s]
    end

    def scholarity_name(scholarity)
      {
        '0' => 'Diploma',
        '1' => 'Laurea Triennale',
        '2' => 'Laurea a Ciclo Unico',
        '3' => 'Laurea Magistrale',
        '4' => 'Laurea Specialistica',
        '5' => 'Master',
        '6' => 'Studi conclusi',
      }[scholarity.to_s]
    end

    def update_podio_id(podio_id)
      return false unless podio_id

      @exchange_participant.update_attribute(:podio_id, podio_id)
    end

    def birthdate_to_podio(birthdate)
      { 'start' => birthdate.strftime('%Y-%m-%d %H:%M:%S') }
    end

    def cellphone_to_podio(cellphone)
      [{ 'type' => 'home', 'value' => cellphone }]
    end

    def email_to_podio(email)
      [{ 'type' => 'home', 'value' => email }]
    end

    def id_to_podio(incoming)
      incoming.to_i
    end

    def program_to_podio(program)
      { gv: 1, ge: 2, gt: 3 }[program.to_sym]
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
  end
end
