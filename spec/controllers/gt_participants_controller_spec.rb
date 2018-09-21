require 'rails_helper'

RSpec.describe GtParticipantsController, type: :controller do
  let(:english_level) { build(:english_level) }
  let(:exchange_participant) { build(:exchange_participant) }
  let(:experience) { build(:experience) }
  let(:gt_participant) do
    build(:gt_participant, english_level: english_level,
                           exchange_participant: exchange_participant,
                           experience: experience)
  end

  describe '#create', aws: true do
    subject(:do_create) { post :create, params: { gt_participant: gt_params } }

    let(:gt_params) do
      {
        fullname: gt_participant.fullname,
        email: gt_participant.email,
        cellphone: gt_participant.cellphone,
        birthdate: gt_participant.birthdate,
        english_level: gt_participant.english_level.to_s,
        scholarity: gt_participant.scholarity,
        experience: {
          language: experience.language,
          marketing: experience.marketing,
          information_technology: experience.information_technology,
          management: experience.management
        },
        local_committee_id: exchange_participant.local_committee_id,
        college_course_id: exchange_participant.college_course_id,
        university_id: exchange_participant.university_id,
        password: exchange_participant.password
      }
    end
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }

    context 'when successful' do
      before { SignUpWorker.stub(:perform_async) }

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GtParticipant, :count).by 1 }
      it { expect { do_create }.to change(EnglishLevel, :count).by 1 }
      it { expect { do_create }.to change(Experience, :count).by 1 }
      it 'sends message to sqs' do
        do_create

        expect(SignUpWorker).to have_received(:perform_async)
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
          .to receive(:gt_participant).and_return(participant_double)
      end

      let(:participant_double) { instance_double(GtParticipant) }
      let(:errors) { instance_double(ActiveModel::Errors) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GtParticipant, :count) }
      it { expect { do_create }.not_to change(EnglishLevel, :count) }
      it { expect { do_create }.not_to change(Experience, :count) }

      describe 'response' do
        it { expect(response['status']).to eq 'failure' }
      end
    end
  end
end
