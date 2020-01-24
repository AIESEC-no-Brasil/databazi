class RdstationWorker
  include Shoryuken::Worker

  QUEUE_NAME = 'rdstation_queue'.freeze

  shoryuken_options queue: QUEUE_NAME,
                    auto_delete: false,
                    body_parser: JSON

  def perform(sqs_msg, body)
    sqs_msg.delete if upsert(body)
  end

  private

  def upsert(params)
    @exchange_participant = ExchangeParticipant.find_by(id: params['exchange_participant_id'])

    integrator = RdstationIntegration.new

    res = integrator.upsert_contact(@exchange_participant.email, contact_info)

    if res['uuid']
      @exchange_participant.update_attribute(:rdstation_uuid, res['uuid'])

      integrator.update_funnel(@exchange_participant.rdstation_uuid, { lifecycle_stage: 'Qualified Lead', opportunity: false })

      integrator.create_conversion_event(@exchange_participant.email, @exchange_participant.exchange_reason) if @exchange_participant.try(:exchange_reason)

    end

    res
  end

  def contact_info
    fields = {
      name: @exchange_participant.fullname,
      mobile_phone: @exchange_participant.cellphone,
      cf_birthday: @exchange_participant.birthdate,
      cf_allow_phone_communication: @exchange_participant.cellphone_contactable ? 'True' : 'False',
      cf_terms_conditions: 'True',
      cf_databazi_id: @exchange_participant.id.to_s,
      cf_newsletter_interest: newsletter_interest(@exchange_participant.program_symbol),
      cf_product: product_registered_to(@exchange_participant.program_symbol),
      cf_not_finished_form: 'False',
      cf_home_lc: @exchange_participant.local_committee.name,
    }

    fields.store('cf_english_level', english_level_name(@exchange_participant&.registerable&.english_level)) if @exchange_participant.registerable.try(:english_level)
    fields.store('cf_subproduct_of_interest', subproduct_of_interest_name(@exchange_participant.registerable.subproduct)) if @exchange_participant.registerable.try(:subproduct)
    fields.store('cf_work_experience', work_experience_name(@exchange_participant.registerable.work_experience)) if @exchange_participant.registerable.try(:work_experience)
    fields.store('cf_education_level', scholarity_name(@exchange_participant.scholarity)) if @exchange_participant.scholarity
    fields.store('cf_region', @exchange_participant.department) if @exchange_participant.try(:department)
    fields.store('city', @exchange_participant.city) if @exchange_participant.try(:city)
    fields.store('cf_conversion_events', @exchange_participant.exchange_reason) if @exchange_participant.try(:exchange_reason)
    fields.store('cf_referral', referral_type_translation(@exchange_participant.referral_type)) if @exchange_participant.try(:referral_type)
    fields.store('cf_university', @exchange_participant.university_name) if @exchange_participant.try(:university_name)

    fields
  end

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
      'class_presentation' => 'Presentazione in classe',
      'informative_banquet' => 'Banchetto informativo'
    }[referral_type]
  end

  def product_registered_to(program)
    { gv: 'GV', ge: 'GE', gt: 'GT' }[program]
  end

  def newsletter_interest(program)
    { gv: 'Volontariato', ge: 'Stage in Startup', gt: 'Stage in Aziende' }[program]
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
end
