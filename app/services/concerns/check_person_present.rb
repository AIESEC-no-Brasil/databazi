require 'graphql/client'
require 'graphql/client/http'

module EXPAAPI
	def self.access_token
		HTTParty
			.get("http://token.aiesec.org.br/get_token.php?token=#{token_token}")
			.body
	end

	def self.token_token
		Rails.application.credentials.api_authenticity_token
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
	}
}
GRAPHQL
