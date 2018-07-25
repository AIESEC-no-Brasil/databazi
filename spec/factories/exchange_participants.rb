FactoryBot.define do
  factory :exchange_participant do
    fullname { Faker::Name.name }
    cellphone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    birthdate { Faker::Date.birthday(18, 65) }
    local_committee
  end
end
