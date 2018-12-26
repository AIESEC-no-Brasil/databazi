FactoryBot.define do
  factory :application, :class => Expa::Application do
    id { Faker::Number.number(5) }
  end
end
