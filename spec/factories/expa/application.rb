FactoryBot.define do
  factory :application, :class => Expa::Application do
    id { Faker::Number.number(5) }
    updated_at { Faker::Date.backward }
    updated_at_expa { Faker::Date.backward }
    applied_at { Faker::Date.backward }
    accepted_at { Faker::Date.backward }
    approved_at { Faker::Date.backward }
    break_approved_at { Faker::Date.backward }
    association :exchange_participant, :for_gv_participant
    # after(:create) do |application, evaluator|
    #   create_list([:exchange_participant, , 1, :for_gv_participant, expa_applications: [application])
    # end
  end
end
