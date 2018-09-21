FactoryBot.define do
  factory :campaign do
    sequence(:source) { |n| "Source#{n}" }
    sequence(:medium) { |n| "Medium#{n}" }
    sequence(:campaign) { |n| "Campaign#{n}" }
  end
end
