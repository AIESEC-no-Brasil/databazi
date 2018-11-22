class ApplicationController < ActionController::API
  def application_region
    ENV['COUNTRY'] or raise KeyError.new 'COUNTRY variable must be declared'
  end
end
