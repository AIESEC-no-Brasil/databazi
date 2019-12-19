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
      date_realized: { from: $from }
    }) {
      paging {
        total_pages
      }
      data{
        id
        status
        updated_at
        created_at
        matched_or_rejected_at
        date_matched
        date_approved
        date_realized
        experience_end_date
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
          email
          secure_identity_email
          status
        }
        opportunity {
          id
          programme {
            short_name_display
          }
        }
        standards{
          constant {
            name
          }
          standard_option {
            name
            option
          }
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
