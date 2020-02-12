require 'graphql/client'
require 'graphql/client/http'

module EXPAAPI
  def self.access_token
    ENV['EXPA_TOKEN']
  end


  HTTP = GraphQL::Client::HTTP.new("https://gis-api.aiesec.org/graphql?access_token=#{access_token}")
  Schema = GraphQL::Client.load_schema(HTTP)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end

ExistsQuery = EXPAAPI::Client.parse <<-'GRAPHQL'
  query($email: String) {
      checkPersonPresent(email: $email) {
        id
        full_name
        email
        status
        dob
        home_lc {
          name
        }
        programmes {
          short_name_display
        }
      }
    }
GRAPHQL
