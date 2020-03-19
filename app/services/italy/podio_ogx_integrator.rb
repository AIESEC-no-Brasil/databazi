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
        'product' => product_registered_to(exchange_participant.program_symbol),
        'local-committee' => local_committee_category_id(@exchange_participant.local_committee.name),
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

      podio_params.store('referral', referral_type_translation(@exchange_participant.referral_type)) if @exchange_participant.referral_type

      podio_id = RepositoryPodio.create_ep(ENV['PODIO_APP_LEADS_OGX'], podio_params).item_id

      @status = update_podio_id(podio_id)

      if podio_id && @exchange_participant.campaign
        campaign = @exchange_participant.campaign
        campaign_tag = "#{campaign.utm_campaign} | #{campaign.utm_medium} | #{campaign.utm_content}"

        Podio::Tag.create('item', podio_id, [campaign_tag])
      end

      @status
    end

    private

    def referral_type_translation(referral_type)
      return 'Altro' unless referral_type

      {
        'facebook_ad' => 'Facebook',
        'instagram_ad' => 'Instagram',
        'friend' => 'Amici',
        'teacher' => 'Professore',
        'event_or_fair' => 'Evento',
        'flyer' => 'Volantini o Poster',
        'search_engine' => 'Motore di ricerca',
        'email' => 'Email',
        'other_website' => 'Altre Sitio Web',
        'other' => 'Altro',
      }[referral_type]
    end

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

    def product_registered_to(program)
      { gv: 1, ge: 2, gt: 3 }[program]
    end

    def local_committee_category_id(local_committee)
      {
        "Ancona" => 1,
        "Bari" => 2,
        "Bologna" => 3,
        "Brescia" => 4,
        "Cagliari" => 5,
        "Catania" => 6,
        "Ferrara" => 7,
        "Firenze" => 8,
        "Genova" => 9,
        "Lecce" => 10,
        "Milano" => 11,
        "Napoli Federico II" => 12,
        "Napoli Parthenope" => 13,
        "Padova" => 14,
        "Palermo" => 15,
        "Parma" => 16,
        "Pavia" => 17,
        "Perugia" => 18,
        "PoliTO" => 19,
        "Roma Sapienza" => 20,
        "Roma Tor Vergata" => 21,
        "Roma Tre" => 22,
        "Torino" => 23,
        "Trento" => 24,
        "Trieste" => 25,
        "Urbino" => 26,
        "Venezia" => 27,
        "Verona" => 28,
      }[local_committee]
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
