module ScholarityUtility
  def scholarity_length
    if ENV['COUNTRY'] == 'bra'
      ExchangeParticipant::BRAZILIAN_SCHOLARITY.length
    else
      ExchangeParticipant::ARGENTINEAN_SCHOLARITY.length
    end
  end
end
