class YouthValidator < ActiveModel::Validator
  def validate(record)
    return if record.icx?
    return if record.birthdate && record.birthdate <= 18.years.ago &&
              record.birthdate >= 30.years.ago

    record.errors[:birthdate] << 'Necessário ter entre 18 e 30 anos.'
  end
end
