FactoryBot.define do
  factory :gt_participant do
    preferred_destination { :brazil }
    curriculum { Rack::Test::UploadedFile.new('files/spec.pdf', 'application/pdf') }
  end
end
