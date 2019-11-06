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

      podio_params = {        
        'title' => @exchange_participant.fullname,
        'email2' => @exchange_participant.email,
        'birthdate2' => birthdate_to_podio(@exchange_participant.birthdate),
        'city' => @exchange_participant.city,
        'region' => @exchange_participant.department,
        'university' => @exchange_participant.university_name,
        'product-registered-to' => exchange_participant.registerable_type.upcase[0..1],
        'home-lc' => @exchange_participant.local_committee.name,
        'home-lc-id' => @exchange_participant.local_committee.id.to_s,
        'home-lc-expa-id' => @exchange_participant.local_committee.expa_id.to_s,
        'databazi-id' => @exchange_participant.id.to_s
      }      

      podio_params.store('cellphone2', @exchange_participant.cellphone) if @exchange_participant.cellphone_contactable

      podio_params.store('english-level', english_level_name(@exchange_participant.registerable.english_level)) if @exchange_participant.registerable.try(:english_level)

      podio_params.store('subproduct-of-interest', subproduct_of_interest_name(@exchange_participant.registerable.subproduct)) if @exchange_participant.registerable.try(:subproduct)

      podio_params.store('work-experience', work_experience_name(@exchange_participant.registerable.work_experience)) if @exchange_participant.registerable.try(:work_experience)

      podio_params.store('education-level', scholarity_name(@exchange_participant.scholarity)) if @exchange_participant.scholarity

      podio_params.store('expa-id', @exchange_participant.expa_id.to_s) if @exchange_participant.expa_id

      podio_params.store('form-id', @exchange_participant.exchange_reason) if @exchange_participant.exchange_reason

      podio_params.store('referral', @exchange_participant.referral_type) if @exchange_participant.referral_type

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
      birthdate.strftime('%Y-%m-%d')
    end
        
  end
end
