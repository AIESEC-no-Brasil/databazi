require 'graphql/client'
require 'graphql/client/http'

module EXPAAPI
  def self.access_token
    HTTParty
      .get("http://token.aiesec.org.br/" \
        "get_token.php?token=#{token_token}"
      )
      .body
  end

  def self.token_token
    ENV['API_AUTHENTICITY_TOKEN']
  end

  HTTP = GraphQL::Client::HTTP.new("https://gis-api.aiesec.org/graphql?access_token=#{access_token}")
  Schema = GraphQL::Client.load_schema(HTTP)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end

ExistsQuery = EXPAAPI::Client.parse <<~'GRAPHQL'
    query($email: String) {
      checkPersonPresent(email: $email) {
        id
        full_name
        email
    }
}
GRAPHQL

LoadApplications = EXPAAPI::Client.parse <<~'GRAPHQL'
  query($from: DateTime) {
    allOpportunityApplication(
      sort: "ASC_updated_at",
      filters:{
      person_home_mc: 1606,
      last_interaction: {from: $from}
    }) {
      paging {
        total_pages
      }
      data{
        id
        status
        updated_at
        created_at
        date_approved
        matched_or_rejected_at
        host_lc_name
        person {
          id
          full_name
          phone
          home_mc {
            name
          }
          home_lc {
            name
          }
          user_id
          email
          secure_identity_email
          status
        }
      }
    }
  }
GRAPHQL

CountApplications = EXPAAPI::Client.parse <<~'GRAPHQL'
  query($from: DateTime, $to: DateTime) {
    allOpportunityApplication(filters:{
      person_home_mc: 1606,
      last_interaction: {from: $from, to: $to}
    }) {
      paging {
        total_pages
      }
    }
  }
GRAPHQL
