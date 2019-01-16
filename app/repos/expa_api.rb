require "#{Rails.root}/lib/expa_api"

module Repos
  class ExpaAPI
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
        # File.write("#{Rails.root}/spec/fixtures/json/icx_applications_full.json", res.to_h.to_json)
        # &.data&.all_opportunity_application&.data
      end

      private

      def map_applications(expa_applications)
        mapped = expa_applications&.data&.all_opportunity_application&.data&.map do |expa_application|
          application = Expa::Application.new
          application.updated_at_expa = Time.parse(expa_application.updated_at)
          application.status = expa_application.status
          application.expa_id = expa_application.id
          application.expa_ep_id = expa_application.person.id
          application.applied_at = parse_time(expa_application.created_at)
          application.approved_at = parse_time(expa_application.date_approved)
          # The two date are the same from expa. Relies on status
          application.accepted_at = parse_time(expa_application.matched_or_rejected_at)
          application.break_approved_at = parse_time(expa_application.matched_or_rejected_at)
          application.sdg_goal_index = expa_application&.opportunity&.sdg_info&.sdg_target&.goal_index
          application.sdg_target_index = expa_application&.opportunity&.sdg_info&.sdg_target&.target_index
          application.opportunity_expa_id = expa_application&.opportunity&.id
          application.opportunity_name = expa_application&.opportunity&.title
          ep = ExchangeParticipant.new(
            fullname: expa_application&.person&.full_name,
            email: expa_application&.person&.email,
            cellphone: expa_application&.person&.phone,
          )
          application.exchange_participant = ep
          # application.save
          application
        end
        mapped
      end

      def parse_time(date)
        date.nil? ? nil : Time.parse(date)
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
          created_at
          date_approved
          matched_or_rejected_at
          person {
            id
            full_name
            email
            phone
          }
          host_lc {
            name
          }
          home_mc {
            name
          }
          opportunity {
            id
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
            sdg_info {
              sdg_target {
                goal_index
                target_index
              }
            }
          }
        }
      }
    }
  GRAPHQL
end
