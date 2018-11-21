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
      'email' => ge_participant.email, 'fullname' => ge_participant.fullname,
      'cellphone' => ge_participant.cellphone,
      'birthdate' => ge_participant.birthdate,
      'utm_source' => utm_source, 'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign, 'utm_term' => utm_term,
      'utm_content' => utm_content, 'podio_app' => 170_576_29,
      'scholarity' => scholarity_human_name,
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
      'email' => ge_participant.email,
      'fullname' => ge_participant.fullname,
      'cellphone' => ge_participant.cellphone,
      'birthdate' => ge_participant.birthdate,
      'utm_source' => utm_source,
      'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign,
      'utm_term' => utm_term,
      'utm_content' => utm_content,
      'podio_app' => 170_576_29,
      'scholarity' => scholarity_human_name,
      'local_committee' => ge_participant.exchange_participant&.local_committee&.podio_id,
      'university' => ge_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => ge_participant.exchange_participant&.college_course&.podio_item_id,
      'other_university' => "",
      'when_can_travel' => ge_participant.when_can_travel
    }
  end

end
