FactoryBot.define do
  factory :member_committee do
    name { Faker::Address.city }
    expa_id { Faker::Number.number(3) }
    podio_id { Faker::Number.number(9) }
  end
end
