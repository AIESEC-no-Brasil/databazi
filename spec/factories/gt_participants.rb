FactoryBot.define do
  factory :gt_participant do
    preferred_destination { 1 }
    curriculum { Rack::Test::UploadedFile.new('files/spec.pdf', 'application/pdf') }
  end
end
