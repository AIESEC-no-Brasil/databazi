require 'rails_helper'

RSpec.describe GvParticipantsController, type: :controller do
  let(:exchange_participant) { build(:exchange_participant) }
  let(:gv_participant) do
    build(:gv_participant, exchange_participant: exchange_participant)
  end

  describe "#create" do
    subject(:do_create) { post :create, params: { gv_participant: gv_params } }

    let(:gv_params) do
      {
        fullname: gv_participant.fullname,
        email: gv_participant.email,
        cellphone: gv_participant.cellphone,
        birthdate: gv_participant.birthdate,
        local_committee_id: exchange_participant.local_committee_id,
        university_id: exchange_participant.university_id
      }
    end
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }
    context "success" do
      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GvParticipant, :count).by 1 }

      describe "response" do
        it { expect(response['status']).to eq 'success' }
      end
    end

    context "failure" do
      before { allow_any_instance_of(GvParticipant).to receive(:save).and_return(false) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GvParticipant, :count) }

      describe "response" do
        it { expect(response['status']).to eq 'failure' }
      end
    end
  end

end
