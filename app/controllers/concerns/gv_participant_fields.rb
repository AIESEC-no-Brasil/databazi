module GvParticipantFields
  def gv_participant_fields
    if ENV['COUNTRY'] == 'bra'
      gv_participant_fields_bra
    else
      gv_participant_fields_arg
    end
  end

  def gv_participant_fields_bra
    {
      'exchange_participant_id' => gv_participant.exchange_participant.id,
      'email' => gv_participant.email,
      'fullname' => gv_participant.fullname,
      'cellphone' => gv_participant.cellphone,
      'birthdate' => gv_participant.birthdate,
      'utm_source' => utm_source,
      'utm_campaign' => utm_campaign,
      'utm_medium' => utm_medium,
      'utm_content' => utm_content,
      'local_committee' => gv_participant.exchange_participant&.local_committee&.podio_id,
      'college_course' => gv_participant.exchange_participant&.college_course&.podio_item_id,
      'cellphone_contactable' => gv_participant.exchange_participant.cellphone_contactable,
      'signup_source' => gv_participant.exchange_participant.signup_source,
      'program' => 'gv',
      'podio_app' => ENV['PODIO_APP_GV']
    }
  end

  def gv_participant_fields_arg
    {
      'exchange_participant_id' => gv_participant.exchange_participant.id,
      'email' => gv_participant.email,
      'fullname' => gv_participant.fullname,
      'cellphone' => gv_participant.cellphone,
      'birthdate' => gv_participant.birthdate,
      'utm_source' => utm_source,
      'utm_medium' => utm_medium,
      'utm_campaign' => utm_campaign,
      'utm_term' => utm_term,
      'utm_content' => utm_content,
      'podio_app' => ENV['PODIO_APP_GV'],
      'scholarity' => gv_participant.scholarity,
      'local_committee' => gv_participant.exchange_participant&.local_committee&.podio_id,
      'university' => gv_participant.exchange_participant&.university&.podio_id,
      'college_course' => gv_participant.exchange_participant&.college_course&.podio_id,
      'when_can_travel' => gv_participant&.read_attribute_before_type_cast(:when_can_travel),
      'other_university' => gv_participant.exchange_participant&.other_university,
      'cellphone_contactable' => gv_participant.exchange_participant.cellphone_contactable,
      'referral_type' => gv_participant.exchange_participant&.read_attribute_before_type_cast(:referral_type)
    }
  end
end
