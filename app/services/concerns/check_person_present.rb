require 'graphql/client'
require 'graphql/client/http'

module EXPAAPI
  def self.access_token
    HTTParty.post(ENV['TOKEN_URL'], body: token_body ).body
  end

  def self.token_body
    { username: ENV['EXPA_USERNAME'], password: ENV['EXPA_PASSWORD'] }.to_json
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
