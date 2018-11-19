class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum_name(enum_name, enum_value)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}"\
      ".#{enum_name.to_s.pluralize}.#{enum_value}")
  end

  private

  def application_region
    raise KeyError unless ENV['COUNTRY'].present?

    ENV['COUNTRY']
  end

  def argentina?
    application_region == 'arg'
  end
end
