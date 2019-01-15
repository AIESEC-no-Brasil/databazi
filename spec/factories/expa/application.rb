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
    email { Faker::Internet.email }
    birthdate { Faker::Date.birthday(18, 30) }
  end
  factory :icx_application_podio, :class => Expa::Application do
    expa_ep_id { Faker::Number.number(5) }
    updated_at_expa { Time.parse('2019-01-06T10:15:14Z') }
    status { :applied }
    expa_id { '4941872' }
    association :exchange_participant, factory: :icx_application_ep
    association :host_lc, factory: :local_committee, podio_id: 306818877
    association :home_lc, factory: :local_committee, podio_id: 306818877
    applied_at { Faker::Date.backward }
    accepted_at { Faker::Date.backward }
    approved_at { Faker::Date.backward }
    break_approved_at { Faker::Date.backward }
    academic_experience { Faker::Lorem.sentence }
    opportunity_name { Faker::Lorem.sentence }
    opportunity_expa_id { Faker::Number.number(5) }
    sdg_target_index { 1 }
    sdg_goal_index { 1 }
  end
  factory :icx_application_expa, :class => Expa::Application do
    updated_at_expa { Time.parse('2019-01-06T10:15:14Z') }
    expa_id { '4941872' }
    status { :open }
    # expa_ep_id { Faker::Number.number(5) }
    # association :exchange_participant, factory: :icx_application_ep
    # association :host_lc, factory: :local_committee, podio_id: 306818877
    # association :home_lc, factory: :local_committee, podio_id: 306818877
    # applied_at { Faker::Date.backward }
    # accepted_at { Faker::Date.backward }
    # approved_at { Faker::Date.backward }
    # break_approved_at { Faker::Date.backward }
    # academic_experience { Faker::Lorem.sentence }
    # opportunity_name { Faker::Lorem.sentence }
    # opportunity_expa_id { Faker::Number.number(5) }
    # sdg_target_index { 1 }
    # sdg_goal_index { 1 }
  end
end
