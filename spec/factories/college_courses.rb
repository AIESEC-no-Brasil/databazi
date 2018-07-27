FactoryBot.define do
  factory :college_course do
    name { Faker::University.name }
    sequence(:podio_id) { |n| "Universidade#{n}" }
  end
end
