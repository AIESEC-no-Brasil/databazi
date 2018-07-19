require 'rails_helper'

RSpec.describe GvParticipantsController, type: :controller do
  let(:gv_participant) { create(:gv_participant) }
  let(:exchange_participant) { create(:exchange_participant, registerable: gv_participant) }

  describe "#create" do
    before { exchange_participant }
    subject(:do_create) { post :create, params: { gv_participant: gv_params } }

    let(:gv_params) do
      { fullname: 'test', email: 'email', cellphone: 'phone', birthdate: Date.today }
    end
    context "success" do
      it { is_expected.to be_successful }

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GvParticipant, :count).by 1 }
    end

    context "failure" do
      before { allow_any_instance_of(GvParticipant).to receive(:save).and_return(false) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GvParticipant, :count) }
    end
  end

end
