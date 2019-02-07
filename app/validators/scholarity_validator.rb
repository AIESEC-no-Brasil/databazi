class ScholarityValidator < ActiveModel::Validator
  def validate(record)
    return if record.scholarity < scholarity_length

    record.errors[:scholarity] << "Informa uma opção válida 0-#{scholarity_length - 1}"
  end

  private

  def scholarity_length
    if ENV['COUNTRY'] == 'bra'
      ExchangeParticipant::BRAZILIAN_SCHOLARITY.length
    else
      ExchangeParticipant::ARGENTINEAN_SCHOLARITY.length
    end
  end
end

