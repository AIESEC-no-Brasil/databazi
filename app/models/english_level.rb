class EnglishLevel < ApplicationRecord
  belongs_to :englishable, polymorphic: true

  enum english_level: [:none, :basic, :intermediate, :advanced, :fluent],
    _suffix: true
end
