FactoryBot.define do
  factory :ge_participant do
    spanish_level { 1 }
    when_can_travel { :as_soon_as_possible }
    preferred_destination { :brazil }
    curriculum { Rack::Test::UploadedFile.new('files/spec.pdf', 'application/pdf') }
  end
end
