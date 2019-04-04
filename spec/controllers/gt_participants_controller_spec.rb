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
  let(:campaign) { build(:campaign) }

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
        cellphone_contactable: exchange_participant.cellphone_contactable,
        experience: {
          language: experience.language,
          marketing: experience.marketing,
          information_technology: experience.information_technology,
          management: experience.management
        },
        local_committee_id: exchange_participant.local_committee_id,
        college_course_id: exchange_participant.college_course_id,
        university_id: exchange_participant.university_id,
        password: exchange_participant.password,
        utm_source: campaign.utm_source,
        utm_medium: campaign.utm_medium,
        utm_campaign: campaign.utm_campaign,
        utm_term: campaign.utm_term,
        utm_content: campaign.utm_content,
        preferred_destination: gt_participant.read_attribute_before_type_cast(:preferred_destination),
        curriculum: fixture_file_upload('files/spec.pdf', 'application/pdf'),
        referral_type: 1,
        city: exchange_participant.city,
        work_experience: 1
      }
    end
    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }

    context 'when successful' do
      before { allow(SignUpWorker).to receive(:perform_async) }

      it { expect { do_create }.to change(ExchangeParticipant, :count).by 1 }
      it { expect { do_create }.to change(GtParticipant, :count).by 1 }
      it { expect { do_create }.to change(EnglishLevel, :count).by 1 }
      it { expect { do_create }.to change(Experience, :count).by 1 }
      it { expect { do_create }.to change(Campaign, :count).by 1 }
      it { expect { do_create }.to change(ActiveStorage::Attachment, :count).by 1 }

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
        allow(ep_double)
          .to receive(:campaign=).and_return(nil)
        allow(controller)
          .to receive(:gt_participant).and_return(participant_double)
        allow(participant_double)
          .to receive(:exchange_participant).and_return(ep_double)
      end

      let(:participant_double) { instance_double(GtParticipant) }
      let(:ep_double) { instance_double(ExchangeParticipant) }
      let(:errors) { instance_double(ActiveModel::Errors) }

      it { expect { do_create }.not_to change(ExchangeParticipant, :count) }
      it { expect { do_create }.not_to change(GtParticipant, :count) }
      it { expect { do_create }.not_to change(EnglishLevel, :count) }
      it { expect { do_create }.not_to change(Experience, :count) }
      it { expect { do_create }.not_to change(Campaign, :count) }
      it { expect { do_create }.not_to change(ActiveStorage::Attachment, :count) }

      describe 'response' do
        it { expect(response['status']).to eq 'failure' }
      end
    end
  end
end
