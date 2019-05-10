FactoryBot.define do
  factory :local_committee do
    name { Faker::Address.city }
    expa_id { Faker::Number.number(3) }
    podio_id { Faker::Number.number(9) }
    whatsapp_link { 'http://wa.me/99999999999' }
  end
end
