require 'graphql/client'
require 'graphql/client/http'

module EXPAAPI
  def self.access_token
    HTTParty.get("#{ENV['TOKEN_URL']}?token=#{token_token}").body
  end

  def self.token_token
    ENV['API_AUTHENTICITY_TOKEN']
  end

  HTTP = GraphQL::Client::HTTP.new("https://gis-api.aiesec.org/graphql?access_token=#{access_token}")
  Schema = GraphQL::Client.load_schema(HTTP)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end

ExistsQuery = EXPAAPI::Client.parse <<-'GRAPHQL'
  query($email: String) {
    checkPersonPresent(email: $email) {
    full_name
    email
    id
  }
}
GRAPHQL
