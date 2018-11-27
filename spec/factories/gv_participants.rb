FactoryBot.define do
  factory :gv_participant do
    when_can_travel { :as_soon_as_possible }
  end
end
