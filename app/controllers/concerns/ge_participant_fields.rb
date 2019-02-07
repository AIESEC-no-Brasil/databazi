module GeParticipantFields
  def ge_participant_fields
    if ENV['COUNTRY'] == 'bra'
      ge_participant_fields_bra
    else
      ge_participant_fields_arg
    end
  end

  def ge_participant_fields_bra
    {
      'exchange_participant_id' => ge_participant.exchange_participant.id,
      'email' => ge_participant.email, 'fullname' => ge_participant.fullname,
      'cellphone' => ge_participant.cellphone,
      'birthdate' => ge_participant.birthdate,
      'utm_source' => utm_source, 'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign, 'utm_term' => utm_term,
      'utm_content' => utm_content, 'podio_app' => ENV['PODIO_APP_GE'],
      'scholarity' => scholarity,
      'local_committee' => ge_participant.exchange_participant&.local_committee&.podio_id,
      'spanish_level' => ge_participant.read_attribute_before_type_cast(:spanish_level),
      'english_level' => ge_participant&.english_level&.read_attribute_before_type_cast(:english_level),
      'university' => ge_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => ge_participant.exchange_participant&.college_course&.podio_item_id,
      'cellphone_contactable' => ge_participant.exchange_participant.cellphone_contactable
    }
  end

  def ge_participant_fields_arg
    {
      'exchange_participant_id' => ge_participant.exchange_participant.id,
      'email' => ge_participant.email,
      'fullname' => ge_participant.fullname,
      'cellphone' => ge_participant.cellphone,
      'birthdate' => ge_participant.birthdate,
      'utm_source' => utm_source,
      'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign,
      'utm_term' => utm_term,
      'utm_content' => utm_content,
      'podio_app' => ENV['PODIO_APP_GE'],
      'scholarity' => scholarity,
      'local_committee' => ge_participant.exchange_participant&.local_committee&.podio_id,
      'university' => ge_participant.exchange_participant&.university&.podio_id,
      'college_course' => ge_participant.exchange_participant&.college_course&.podio_id,
      'other_university' => ge_participant.exchange_participant&.other_university,
      'english_level' => ge_participant&.english_level&.read_attribute_before_type_cast(:english_level),
      'when_can_travel' => ge_participant&.read_attribute_before_type_cast(:when_can_travel),
      'preferred_destination' => ge_participant&.read_attribute_before_type_cast(:preferred_destination),
      'cellphone_contactable' => ge_participant.exchange_participant.cellphone_contactable
    }
  end
end
