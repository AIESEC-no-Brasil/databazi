class ScholarityValidator < ActiveModel::Validator
  include ScholarityUtility

  def validate(record)
    return if record.scholarity < scholarity_length

    record.errors[:scholarity] << "Informa uma opção válida 0-#{scholarity_length - 1}"
  end
end

