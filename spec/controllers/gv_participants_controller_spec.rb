require 'rails_helper'

RSpec.describe GvParticipantsController, type: :controller do
  let(:exchange_participant) { build(:exchange_participant) }
  let(:gv_participant) do
    build(:gv_participant, exchange_participant: exchange_participant)
  end

  describe '#create', aws: true do
    subject(:do_create) { post :create, params: { gv_participant: gv_params } }

    let(:gv_params) do
      {
        fullname: gv_participant.fullname,
        email: gv_participant.email,
        cellphone: gv_participant.cellphone,
        birthdate: gv_participant.birthdate,
        local_committee_id: exchange_participant.local_committee_id,
        college_course_id: exchange_participant.college_course_id,
        university_id: exchange_participant.university_id,
        password: exchange_participant.password,
        scholarity: gv_participant.scholarity
      }
    end
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }
    context 'when successful' do
      before do
        SignUpWorker.stub(:perform_async)
        SendToPodioWorker.stub(:perform_async)
        SendToPodio.stub(:call)
      end

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GvParticipant, :count).by 1 }
      it 'sends message to sqs' do
        do_create

        expect(SignUpWorker).to have_received(:perform_async)
      end

      it 'sends message to podio' do
        do_create

        expect(SendToPodioWorker).to have_received(:perform_async)
      end

      describe 'response' do
        it { expect(response['status']).to eq 'success' }
      end
    end

    context 'when unsuccessful' do
      before do
        allow(participant_double).to receive(:save).and_return(false)
        allow(errors).to receive(:messages).and_return(['error'])
        allow(participant_double).to receive(:errors).and_return(errors)
        allow(controller)
          .to receive(:gv_participant).and_return(participant_double)
      end

      let(:participant_double) { instance_double(GvParticipant) }
      let(:errors) { instance_double(ActiveModel::Errors) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GvParticipant, :count) }

      describe 'response' do
        it { expect(response['status']).to eq 'failure' }
      end
    end
  end
end
