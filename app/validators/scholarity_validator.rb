# Scholarity Custom Validator based upon current country
class ScholarityValidator < ActiveModel::Validator
  def validate(record)
    return if record.scholarity < record.scholarity_length

    record.errors[:scholarity] << "Informa uma opção válida 0-#{record.scholarity_length - 1}"
  end
end

