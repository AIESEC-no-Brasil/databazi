require "#{Rails.root}/lib/expa_api"

class ExpaApplicationSync
  def self.call
    new.call
  end

  def initialize
  end

  def call
    # DONE get access token
    # access_token
    load_applications.each do |application|
      Expa::Application.create(
        expa_id: application.id,
        status: application.status
      )
      
      # TODO: Get ID of Attendee
      # TODO: Exists on our database?
      # TODO: If not, search the 
    end




    # Considering that EP already has expa_id

    # Fetch number of pages
    # Send SQS message (page_number, filters)
    # Fetch page applications
    # Application.create
    # SendApplicationToPodio

    # Get Applications In graphql
    # Join Applications with EPS
    # Saving Application into PG
    # Saving Application into Podio
    
  end
  
  private

  def access_token
    res = HTTParty
      .get("http://token.aiesec.org.br/" \
        "get_token.php?token=#{token_token}"
      )
      .body
    raise RuntimeError.new('Error fetching Authenticity Token') if res.empty?
    res
  end

  def token_token
    ENV['API_AUTHENTICITY_TOKEN']
  end

  def load_applications
    EXPAAPI::Client.query(
      LoadApplications
    ).data.all_opportunity_application.data
  end
end
