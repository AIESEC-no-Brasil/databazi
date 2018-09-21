FactoryBot.define do
  factory :university do
    name { Faker::University.name }
    sequence(:podio_id) { |n| "Universidade#{n}" }
  end
end
