FactoryBot.define do
  factory :membership do
    fullname { "MyString" }
    cellphone { "MyString" }
    birthdate { "2019-11-29" }
    email { "MyString" }
    city { "MyString" }
    state { "MyString" }
    cellphone_contactable { false }
    college_course { 1 }
    local_committee { 1 }
  end
end
