class ApplicationController < ActionController::API
  def application_region
    raise KeyError unless ENV['COUNTRY'].present?

    ENV['COUNTRY']
  end
end
