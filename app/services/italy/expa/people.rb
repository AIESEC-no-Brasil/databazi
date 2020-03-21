require "#{Rails.root}/lib/expa_api"

module Italy
  module Expa
    class People
      def self.call
        new.call
      end

      def call
        load_expa_people(from) { |person| perform_on_exchange_participant(person) }
      end

      private

      def expa_person_status(status)
        status == 'other' ? 'other_status' : status
      end

      def from
        (ExchangeParticipant
          .where.not(updated_at_expa: nil)
          .order(updated_at_expa: :desc)
          .first&.updated_at_expa  || 1.days.ago) - 1.hour
      end

      def load_expa_people(from, page = 1, &callback)
        res = query_all_people(from)

        total_pages = res&.data&.all_people&.paging&.total_pages

        people = res&.data&.all_people&.data

        people.each do |person|
          begin
            callback.call(person)
          rescue => exception
            Raven.extra_context exchange_participant_expa_id: person.id
            Raven.capture_exception(exception)
            logger = logger || Logger.new(STDOUT)
            logger.error exception.message
            logger.error(exception.backtrace.map { |s| "\n#{s}" })
            break
          end

        end if people

        people = nil

        return load_expa_people(
          from,
          page + 1,
          &callback
        ) unless res.nil? || page + 1 > total_pages
      end

      def perform_on_exchange_participant(person)
        exchange_participant = ExchangeParticipant.find_by(expa_id: person.id)

        return if person.status == 'deleted'

        if exchange_participant
          unless expa_person_status(person.status) == exchange_participant.status
            update_exchange_participant(exchange_participant, person)
          else
            exchange_participant.update_attributes(updated_at_expa: person.updated_at)
          end
        else
          exchange_participant = create_new_exchange_participant(person)
        end

        sleep 3
      end

      def query_all_people(from)
        EXPAAPI::Client.query(
          ALLPEOPLEOGX,
          variables: {
            from: from
          }
        )
      end

      def update_exchange_participant(exchange_participant, person)
        exchange_participant.update_attributes(
          status: expa_person_status(person.status),
          updated_at_expa: person.updated_at,
          birthdate: person.dob,
          first_position_start: first_position_start(person.positions)
          last_position_end: last_position_end(person.positions),
          education_level: person.academic_experiences,
          academic_backgrounds: person.academic_backgrounds,
          city: person.city,
          gender: person.gender,
          expa_id: person.id,
          programmes: selected_programmes(person.profile.selected_programmes),
          lc_alignment: person.lc_alignment.label,
          managers: managers(person.managers),
          opportunity_applications_count: person.opportunity_applications_count
        )

        exchange_participant.update_attribute(:rdstation_sync, true) if exchange_participant.rdstation_uuid
      end

      def managers(managers)
        managers.map { |manager| m.full_name }.join(', ')
      end

      # def selected_programmes(programmes)
      #   translation = { 1: 'GV', 2: 'GE', 5: 'GT' }

      #   selected_programmes << programmes.each { |program| }
      # end

      def first_position_start(positions)
        return unless positions.any?

        first = Date.today

        positions.map { |pos| Date.parse(pos.start_date) < first ? first = Date.parse(pos.start_date) : next }

        first
      end

      def last_position_end(positions)
        return unless positions.any?

        last = Date.new

        positions.map { |pos| Date.parse(pos.end_date) < last ? last = Date.parse(pos.end_date) : next }

        last
      end

      def create_new_exchange_participant(person)
        ExchangeParticipant.new(expa_id: person.id,
                                  updated_at_expa: person.updated_at,
                                  created_at_expa: person.created_at,
                                  fullname: person.full_name,
                                  email: person.email,
                                  birthdate: person.dob,
                                  local_committee: LocalCommittee.find_by(expa_id: person.try(:home_lc).try(:id)),
                                  origin: :expa,
                                  status: expa_person_status(person&.status)
                                ).save(validate: false)
      end
    end
  end
end

ALLPEOPLEOGX = EXPAAPI::Client.parse <<~'GRAPHQL'
  query ($from: DateTime) {
    allPeople(per_page: 500, sort: "+updated_at",
              filters: {
                home_committee: 1542,
                last_interaction: { from: $from }
              }
    ) {
        paging {
          total_pages
          total_items
        }
        data {
          updated_at
          id
          academic_experiences {
            backgrounds {
              name
            }
            experience_level {
              name
            }
          }
          address_detail {
            city
          }
          contact_detail {
            country_code
            facebook
            instagram
            linkedin
            phone
            twitter
            website
          }
          contacted_at
          contacted_by{
            full_name
          }
          created_at
          dob
          email
          follow_up{
            name
          }
          full_name
          gender
          home_lc {
            id
            name
            full_name
          }
          home_mc {
            id
            name
          }
          is_ai_member
          last_active_at
          lc_alignment {
            id
            label
          }
          managers {
            full_name
          }
          meta {
            allow_phone_communication
          }
          opportunity_applications_count
          person_profile {
            selected_programmes

          }
          positions {
            start_date
            end_date
          }
          programmes {
            short_name_display
          }
          secure_identity_email
          status
          referral_type
          tag_lists {
            name
          }
        }
    }
  }
GRAPHQL

