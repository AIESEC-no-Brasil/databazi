require 'rails_helper'

RSpec.describe GtParticipantsController, type: :controller do
  let(:gt_participant) { create(:gt_participant) }
  let(:english_level) { create(:english_level, englishable: gt_participant) }
  let(:exchange_participant) { create(:exchange_participant, registerable: gt_participant) }

  describe "#create" do
    before { exchange_participant }
    subject(:do_create) { post :create, params: { gt_participant: gt_params } }

    let(:gt_params) do
      { fullname: 'test', email: 'email', cellphone: 'phone', birthdate: Date.today,
        english_level: "fluent", scholarity: "graduated", experience: "marketing" }
    end
    context "success" do
      it { is_expected.to be_successful }

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GtParticipant, :count).by 1 }
      it { expect { do_create }.to change(EnglishLevel, :count).by 1 }
    end

    context "failure" do
      before { allow_any_instance_of(GtParticipant).to receive(:save).and_return(false) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GtParticipant, :count) }
      it { expect { do_create }.not_to change(EnglishLevel, :count) }
    end
  end
end
