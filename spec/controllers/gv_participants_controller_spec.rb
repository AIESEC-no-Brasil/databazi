require 'rails_helper'

RSpec.describe GvParticipantsController, type: :controller do
  let(:exchange_participant) { build(:exchange_participant) }
  let(:gv_participant) do
    build(:gv_participant, exchange_participant: exchange_participant)
  end
  let(:campaign) { build(:campaign) }

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
        cellphone_contactable: exchange_participant.cellphone_contactable,
        scholarity: gv_participant.scholarity,
        utm_source: campaign.utm_source,
        utm_medium: campaign.utm_medium,
        utm_campaign: campaign.utm_campaign,
        utm_term: campaign.utm_term,
        utm_content: campaign.utm_content
      }
    end
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }
    context 'when successful' do
      before do
        allow(SignUpWorker).to receive(:perform_async)
        allow(SendToPodioWorker).to receive(:perform_async)
        allow(SendToPodio).to receive(:call)
      end

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GvParticipant, :count).by 1 }
      it { expect { do_create }.to change(Campaign, :count).by 1 }

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
        allow(ep_double)
          .to receive(:campaign=).and_return(nil)
        allow(controller)
          .to receive(:gv_participant).and_return(participant_double)
        allow(participant_double)
          .to receive(:exchange_participant).and_return(ep_double)
      end

      let(:participant_double) { instance_double(GvParticipant) }
      let(:ep_double) { instance_double(ExchangeParticipant) }
      let(:errors) { instance_double(ActiveModel::Errors) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GvParticipant, :count) }
      it { expect { do_create }.not_to change(Campaign, :count) }

      describe 'response' do
        it { expect(response['status']).to eq 'failure' }
      end
    end
  end
end
