FactoryBot.define do
  factory :campaign do
    sequence(:utm_source) { |n| "Source#{n}" }
    sequence(:utm_medium) { |n| "Medium#{n}" }
    sequence(:utm_campaign) { |n| "Campaign#{n}" }
    sequence(:utm_term) { |n| "Term#{n}" }
    sequence(:utm_content) { |n| "Content#{n}" }
  end
end
