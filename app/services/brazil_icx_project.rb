require 'i18n'

class BrazilIcxProject
  def self.call(params)
    new(params).call
  end

  attr_reader :title
  attr_writer :project

  def initialize(title)
    @title = I18n.transliterate(title).downcase
    @project = nil
  end

  def call
    check_pattern_matching
    translate_to_podio
  end

  private

  def check_pattern_matching
    dictionary.each_key do |k|
      @project = k.to_sym if @title.match(Regexp.union(dictionary[k]))
    end
  end

  def dictionary
    {
      giramundo: ['gira mundo', 'giramundo'],
      x4change: ['x4change', 'x4 change'],
      smart: 'smart',
      nos: ['nos ',
            'nos -',
            'nos /',
            'nos-',
            'nos/',
            '[nos]',
            'nos |'],
      planet_heroes: ['planet heroes', 'planetheroes'],
    }
  end

  def translate_to_podio
    @project ? podio_data[@project] : podio_data[:other]
  end

  def podio_data
    {
      giramundo: 1,
      smart: 2,
      x4change: 3,
      planet_heroes: 4,
      nos: 5,
      other: 6
    }
  end
end
