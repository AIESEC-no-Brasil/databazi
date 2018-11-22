FactoryBot.define do
  factory :ge_participant do
    spanish_level { 1 }
    when_can_travel { 1 }
    preferred_destination { 1 }
    curriculum { Rack::Test::UploadedFile.new('files/spec.pdf', 'application/pdf') }
  end
end
