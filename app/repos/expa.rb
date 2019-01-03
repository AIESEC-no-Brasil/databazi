require "#{Rails.root}/lib/expa_api"

module Repos
  class Expa
    class << self
      def load_icx_applications(from, to, page)
        res = EXPAAPI::Client.query(
          ICXAPPLICATIONS,
          variables: {
            to: to,
            from: from,
            page: page
          }
        )
      end
    end
  end

  ICXAPPLICATIONS = EXPAAPI::Client.parse <<~'GRAPHQL'
    query ($from: DateTime, $to: DateTime, $page: Int) {
      allOpportunityApplication(page: $page, filters: {opportunity_home_mc: 1606, last_interaction: {from: $from, to: $to}}) {
        paging {
          total_pages
        }
        data {
          id
          status
          updated_at
          person {
            id
            first_name
            last_name
          }
          host_lc {
            name
          }
          home_mc {
            name
          }
          opportunity {
            title
            managers {
              full_name
              email
            }
            programme {
              id
              short_name
              short_name_display
            }
          }
        }
      }
    }
  GRAPHQL
end
