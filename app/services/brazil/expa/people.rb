require "#{Rails.root}/lib/expa_api"

module Brazil
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
        res = query_all_people(from, page)

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
          update_exchange_participant(exchange_participant, person) unless expa_person_status(person.status) == exchange_participant.status
        else
          exchange_participant = create_new_exchange_participant(person)
        end

        sleep 2
      end

      def query_all_people(from, page)
        EXPAAPI::Client.query(
          ALLPEOPLEOGX,
          variables: {
            from: from,
            page: page
          }
        )
      end

      def update_exchange_participant(exchange_participant, person)
        exchange_participant.update_attributes(status: expa_person_status(person.status), updated_at_expa: person.updated_at)
      end

      def create_new_exchange_participant(person)
        program = (person.programmes.map(&:short_name_display) & %w[GV GE GT]).pop.downcase || 'gv'

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
  query ($from: DateTime, $page: Int) {
    allPeople(per_page: 500, sort: "+updated_at", page: $page,
              filters: {
                home_committee: 1606,
                last_interaction: { from: $from }
              }
    ) {
        paging {
          total_pages
          total_items
        }
        data {
          id
          full_name
          email
          status
          dob

          home_lc {
            id
            name
            full_name
          }

          programmes {
            short_name_display
          }
          created_at
          updated_at
        }
    }
  }
GRAPHQL

