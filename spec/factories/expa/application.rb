FactoryBot.define do
  factory :application, :class => Expa::Application do
    id { Faker::Number.number(5) }
    updated_at { Faker::Date.backward }
    updated_at_expa { Faker::Date.backward }
    association :exchange_participant, :for_gv_participant
    # after(:create) do |application, evaluator|
    #   create_list([:exchange_participant, , 1, :for_gv_participant, expa_applications: [application])
    # end
  end
  factory :icx_application_ep, parent: :ep_gv do
    fullname { 'Carolina Alejandra Tapia Collantes' }
    id { nil }
  end
  factory :icx_application, :class => Expa::Application do
    # id { Faker::Number.number(5) }
    # updated_at { Faker::Date.backward }
    updated_at_expa { Time.parse('2019-01-06T10:15:14Z') }
    status { :open }
    expa_id { '4941872' }
    association :exchange_participant, factory: :icx_application_ep
    exchange_participant_id { nil }
    # after(:create) do |application, evaluator|
    #   create_list([:exchange_participant, , 1, :for_gv_participant, expa_applications: [application])
    # end
  end
end
