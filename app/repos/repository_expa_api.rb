require "#{Rails.root}/lib/expa_api"

class RepositoryExpaApi
  class << self
    def load_icx_applications(from)
      res = EXPAAPI::Client.query(
        ICXAPPLICATIONS,
        variables: {
          from: from
        }
      )
      map_applications(res) unless res.nil?
      # File.write("#{Rails.root}/spec/fixtures/json/icx_applications_full.json", res.to_h.to_json)
      # &.data&.all_opportunity_application&.data
    end

    private

    def map_applications(expa_applications)
      #removing applications with 'TMP' product - we only work with GE, GT and GT products
      mapped = expa_applications&.data&.all_opportunity_application&.data&.reject{ |application| application&.opportunity&.programme&.short_name_display == 'TMP' }
      mapped = mapped.map do |expa_application|
        pp expa_application.to_json
        application = Expa::Application.new
        application.updated_at_expa = Time.parse(expa_application.updated_at)
        application.status = expa_application.status
        application.expa_id = expa_application.id
        application.expa_ep_id = expa_application.person.id
        application.applied_at = parse_time(expa_application.created_at)
        application.approved_at = parse_time(expa_application.date_approved)
        application.realized_at = parse_time(expa_application.date_realized)
        application.completed_at = parse_time(expa_application.experience_end_date)
        # The two date are the same from expa. Relies on status
        application.accepted_at = parse_time(expa_application.matched_or_rejected_at)
        application.break_approved_at = parse_time(expa_application.matched_or_rejected_at) if rejected_application?(expa_application.status)
        application.sdg_goal_index = expa_application&.opportunity&.sdg_info&.sdg_target&.goal_index
        application.sdg_target_index = expa_application&.opportunity&.sdg_info&.sdg_target&.target_index
        application.tnid = expa_application&.opportunity&.id
        application.opportunity_name = expa_application&.opportunity&.title
        application.product = expa_application
          &.opportunity&.programme&.short_name_display&.downcase&.to_sym
        epp = exchange_programme(expa_application)
        ep = ExchangeParticipant.new(
          fullname: expa_application&.person&.full_name,
          email: expa_application&.person&.email,
          cellphone: expa_application&.person&.phone,
          expa_id: expa_application&.person&.id,
          exchange_type: :icx,
          academic_backgrounds: map_academic_experience_of_ep(expa_application)
        )
        application.academic_backgrounds = map_academic_experience_of_op(expa_application)
        ep.registerable = epp
        application.exchange_participant = ep
        member_committee = MemberCommittee.new(
          expa_id: expa_application&.person&.home_mc&.id,
          name: expa_application&.person&.home_mc&.name
        )
        application.home_mc = member_committee
        application.host_lc = LocalCommittee.new(
          expa_id: expa_application&.host_lc&.id,
          name: expa_application&.host_lc&.name
        )
        application.home_lc = LocalCommittee.new(
          expa_id: expa_application&.person&.home_lc&.id,
          name: expa_application&.person&.home_lc&.name
        )
        application.standards = expa_application.standards
        # application.save
        application
      end
      mapped
    end

    def rejected_application?(status)
      status.in?(['break_approved', 'approval_broken', 'rejected'])
    end

    def map_academic_experience_of_ep(expa_application)
      experiences = expa_application
        &.person&.academic_experiences
      backgrounds = []
      experiences.each do |experience|
        experience.backgrounds.map do |background|
          backgrounds.push(background.name)
        end
      end
      backgrounds
    end

    def map_academic_experience_of_op(expa_application)
      backgrounds = expa_application&.opportunity&.backgrounds
      backgrounds.map(&:constant_name)
    end

    def exchange_programme(expa_application)
      name = expa_application&.opportunity&.programme&.short_name_display
      case name
      when 'GT'
        GtParticipant.new
      when 'GV'
        GvParticipant.new
      when 'GE'
        GeParticipant.new
      else
        raise "Invalid program type #{name}"
      end
    end

    def parse_time(date)
      date.nil? ? nil : Time.parse(date)
    end
  end
end

ICXAPPLICATIONS = EXPAAPI::Client.parse <<~'GRAPHQL'
  query ($from: DateTime) {
    allOpportunityApplication(
      sort: "ASC_updated_at",
      filters:{
        opportunity_home_mc: 1606,
        last_interaction: {from: $from}
      }
    ) {
      paging {
        total_pages
      }
      data {
        id
        status
        updated_at
        created_at
        matched_or_rejected_at
        date_approved
        date_realized
        experience_end_date
        person {
          id
          full_name
          email
          phone
          academic_experiences {
            backgrounds {
              name
            }
          }
          home_mc {
            id
            name
          }
          home_lc {
            id
            name
          }
        }
        host_lc {
          id
          name
        }
        home_mc {
          id
          name
        }
        opportunity {
          id
          title
          programme {
            id
            short_name_display
          }
          sdg_info {
            sdg_target {
              goal_index
              target_index
            }
          }
          backgrounds {
            constant_name
          }
        }
        standards{
          constant_name
          option
        }
      }
    }
  }
GRAPHQL
