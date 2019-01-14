FactoryBot.define do
  factory :sync_param do
    podio_application_status_last_sync { Faker::Date.backward }
  end
end
