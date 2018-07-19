require 'rails_helper'

RSpec.describe GeParticipantsController, type: :controller do
  let(:ge_participant) { create(:ge_participant) }
  let(:english_level) { create(:english_level, englishable: ge_participant) }
  let(:exchange_participant) { create(:exchange_participant, registerable: ge_participant) }

  describe "#create" do
    before { exchange_participant }
    subject(:do_create) { post :create, params: { ge_participant: gt_params } }

    let(:gt_params) do
      { fullname: 'test', email: 'email', cellphone: 'phone', birthdate: Date.today,
        english_level: "fluent", spanish_level: "fluent" }
    end
    context "success" do
      it { is_expected.to be_successful }

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GeParticipant, :count).by 1 }
      it { expect { do_create }.to change(EnglishLevel, :count).by 1 }
    end

    context "failure" do
      before { allow_any_instance_of(GeParticipant).to receive(:save).and_return(false) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GeParticipant, :count) }
      it { expect { do_create }.not_to change(EnglishLevel, :count) }
    end
  end
end
