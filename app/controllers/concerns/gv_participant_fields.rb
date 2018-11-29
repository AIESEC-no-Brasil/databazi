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
      'scholarity' => scholarity_human_name,
      'local_committee' => gv_participant.exchange_participant&.local_committee&.podio_id,
      'university' => gv_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => gv_participant.exchange_participant&.college_course&.podio_item_id,
      'cellphone_contactable' => gv_participant.exchange_participant.cellphone_contactable
    }
  end

  def gv_participant_fields_arg
    {
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
      'scholarity' => scholarity_human_name,
      'local_committee' => gv_participant.exchange_participant&.local_committee&.podio_id,
      'university' => gv_participant.exchange_participant&.university&.podio_item_id,
      'college_course' => gv_participant.exchange_participant&.college_course&.podio_item_id,
      'when_can_travel' => gv_participant.when_can_travel
    }
  end
end
