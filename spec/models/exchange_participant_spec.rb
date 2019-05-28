require 'rails_helper'

RSpec.describe ExchangeParticipant, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to respond_to :password }
    it { is_expected.to respond_to :cellphone_contactable }
    it { is_expected.to respond_to :expa_id }
    it { is_expected.to respond_to :referral_type }
    it do
      expect(ExchangeParticipant.new).to define_enum_for(:referral_type)
        .with({ none: 0, friend: 1, friend_facebook: 2, friend_instastories: 3,
                friend_social_network: 4, google: 5, facebook_group: 6, facebook_ad: 7,
                instagram_ad: 8, university_presentation: 9, university_mail: 10,
                university_workshop: 11, university_website: 12, event_or_fair: 13,
                partner_organization: 14, spanglish_event: 15, potenciate_ad: 16, influencer: 17 })
    end
  end

  describe '#constants' do
    describe '#argentinean_scholarity' do
      let(:argentinean_scholarity) { ExchangeParticipant::ARGENTINEAN_SCHOLARITY }
      it { expect(argentinean_scholarity).to match_array(%i[incomplete_highschool highschool graduating graduated post_graduating post_graduated])}
    end

    describe '#brazilian_scholarity' do
      let(:brazilian_scholarity) { ExchangeParticipant::BRAZILIAN_SCHOLARITY }
      it { expect(brazilian_scholarity).to match_array(%i[highschool incomplete_graduation graduating post_graduated almost_graduated graduated other])}
    end
  end

  describe '#associations' do
    it { is_expected.to have_many :expa_applications }

    it { is_expected.to belong_to :registerable }
    it { is_expected.to belong_to :campaign }
    it { is_expected.to belong_to :local_committee }
    it { is_expected.to belong_to :university }
    it { is_expected.to belong_to :college_course }
  end

  describe '#validations' do
    subject { build(:exchange_participant, exchange_type: :ogx) }

    it { is_expected.to validate_presence_of :fullname }
    it { is_expected.to validate_presence_of :cellphone }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of :email }
    # TODO: How to validate by rule of exchange type
    xit { is_expected.to validate_presence_of :password }
    xit { is_expected.to validate_presence_of :birthdate}
    context 'email' do
      let(:exchange_participant) { build(:exchange_participant, email: 'aaaahotmail.com') }

      it 'is invalid when wrong email format provided' do
        expect(exchange_participant.valid?).to eq false
      end

      it 'is valid when correct email format provided' do
        exchange_participant.email = 'test@example.com'

        expect(exchange_participant.valid?).to eq true
      end
    end
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for :campaign }
  end

  describe '#methods' do
    let(:exchange_participant) do
      create(:exchange_participant,
        fullname: 'Forrest Gump',
        registerable: build(:gv_participant), password: 'test')
    end

    describe '#check_segmentation' do
      let(:origin_local_committee) { create(:local_committee) }
      let(:destination_local_committee) { create(:local_committee) }

      let(:local_committee_segmentation) do
        create(:local_committee_segmentation,
               origin_local_committee_id: origin_local_committee.id,
               destination_local_committee_id: destination_local_committee.id,
               program: :ge)
      end

      let(:ge_exchange_participant) do
        build(:exchange_participant, :for_ge_participant,
              local_committee_id: origin_local_committee.id)
      end

      let(:gv_exchange_participant) do
        build(:exchange_participant, :for_gv_participant,
              local_committee_id: origin_local_committee.id)
      end

      context 'when segmentation exists' do
        it 'changes the local_committee_id before creating' do
          ge_exchange_participant.save
          ge_exchange_participant.reload

          expect(ge_exchange_participant.local_committee_id).to eq(destination_local_committee.id)
        end
      end

      context 'when no segmentation exists' do
        it 'doesn\'t change the local_committee_id value' do
          gv_exchange_participant.save
          gv_exchange_participant.reload

          expect(gv_exchange_participant.local_committee_id).to eq(origin_local_committee.id)
        end
      end
    end

    describe '#scholarity_length' do
      context 'arg' do
        before(:each) { ENV['COUNTRY'] = 'arg' }

        it { expect(exchange_participant.scholarity_length).to eq 6 }
      end

      context 'bra' do
        before(:each) { ENV['COUNTRY'] = 'bra' }

        it { expect(exchange_participant.scholarity_length).to eq 7 }
      end
    end

    describe '#decrypted_password' do
      it { expect(exchange_participant.password).not_to eq 'test' }
      it { expect(exchange_participant.decrypted_password).to eq 'test' }

      context 'when changing password' do
        before { exchange_participant.password = 'changed' }

        it { expect(exchange_participant.password).to eq 'changed' }
        it { expect(exchange_participant.decrypted_password).to eq 'changed' }
      end
    end

    describe '#first_name' do
      subject { exchange_participant.first_name }

      it { is_expected.to eq 'Forrest' }
    end

    describe '#last_name' do
      subject { exchange_participant.last_name }

      it { is_expected.to eq 'Gump' }
    end

    describe '#as_sqs' do
      subject { exchange_participant.as_sqs }

      let(:expected) do
        { exchange_participant_id: exchange_participant.id }
      end

      it { is_expected.to match_array expected }
    end

    describe '#most_actual_application' do
      subject { ep.most_actual_application(application) }

      let(:current_application_2_params) { {} }
      let(:current_application_2) { build(:application, current_application_2_params) }
      let(:current_application_params) { {} }
      let(:current_application) { build(:application, current_application_params) }
      let(:application_params) { {} }
      let(:application) { build(:application, application_params) }
      let(:expa_applications) { [] }
      let(:ep) { build(:exchange_participant, expa_applications: expa_applications) }

      context 'without current applications' do
        it { is_expected.to be_equal(application) }
      end

      context 'with a current "open" application compared to another one, but older' do
        let(:current_application_params) { { status: :open, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :open, updated_at_expa: 2.month.ago } }

        it { is_expected.to be_equal(application) }
      end

      context 'with a current "open" application compared to another one, but newer' do
        let(:current_application_params) { { status: :open, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :open, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(current_application) }
      end

      context 'with a current "open" application compared to an "applied"' do
        let(:current_application_params) { { status: :open, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :applied, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(application) }
      end

      context 'with a current "applied" application compared to an "accepted"' do
        let(:current_application_params) { { status: :applied, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :accepted, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(application) }
      end

      context 'with a current "accepted" application compared to an "approved"' do
        let(:current_application_params) { { status: :accepted, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :approved, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(application) }
      end

      context 'with a current "open" application compared to an "rejected"' do
        let(:current_application_params) { { status: :open, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :rejected, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(current_application) }
      end

      context 'with a current "open" application compared to an "break_approved"' do
        let(:current_application_params) { { status: :open, updated_at_expa: 1.month.ago } }
        let(:expa_applications) { [current_application] }
        let(:application_params) { { status: :break_approved, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(current_application) }
      end

      context 'with two "open" applications compared to the "rejected" current application' do
        let(:current_application_params) { { status: :open, updated_at_expa: 1.month.ago } }
        let(:current_application_2_params) { { status: :open, updated_at_expa: 20.day.ago } }
        let(:expa_applications) { [current_application, current_application_2] }
        let(:application_params) { { id: current_application.id, status: :rejected, updated_at_expa: 1.day.ago } }

        it { is_expected.to be_equal(current_application_2) }
      end
    end

    describe '#scholarity_sym' do
      context 'arg' do
        before(:each) { ENV['COUNTRY'] = 'arg' }
        let(:exchange_participant) { build(:exchange_participant, scholarity: 0) }

        it { expect(exchange_participant.scholarity_sym).to eq ExchangeParticipant::ARGENTINEAN_SCHOLARITY.first }
      end

      context 'bra' do
        before(:each) { ENV['COUNTRY'] = 'bra' }
        let(:exchange_participant) { build(:exchange_participant, scholarity: 0) }

        it { expect(exchange_participant.scholarity_sym).to eq ExchangeParticipant::BRAZILIAN_SCHOLARITY.first }
      end
    end
  end

  describe '#custom_validations' do
    describe 'scholarity' do
      let(:exchange_participant) { build(:exchange_participant, registerable: build(:gv_participant)) }

      context 'arg' do
        before(:each) { ENV['COUNTRY'] = 'arg' }
        let(:scholarity_length) { ExchangeParticipant::ARGENTINEAN_SCHOLARITY.length }

        it 'is valid when scholarity is within constant length' do
          exchange_participant.scholarity = scholarity_length - 1
          exchange_participant.valid?

          expect(exchange_participant).to be_valid
        end

        it 'is invalid when sholarity is without constant length' do
          exchange_participant.scholarity = scholarity_length
          exchange_participant.valid?

          expect(exchange_participant).to be_invalid
        end
      end

      context 'bra' do
        before(:each) { ENV['COUNTRY'] = 'bra' }
        let(:scholarity_length) { ExchangeParticipant::BRAZILIAN_SCHOLARITY.length }

        it 'is valid when scholarity is within constant length' do
          exchange_participant.scholarity = scholarity_length - 1
          exchange_participant.valid?

          expect(exchange_participant).to be_valid
        end

        it 'is invalid when sholarity is without constant length' do
          exchange_participant.scholarity = scholarity_length
          exchange_participant.valid?

          expect(exchange_participant).to be_invalid
        end
      end
    end

    # TODO: How to validate by rule of exchange type
    xdescribe 'age validation' do
      let(:younger_than_18) do
        build(:exchange_participant,
          birthdate: 18.years.ago + 1.day,
          registerable: build(:gv_participant))
      end
      let(:older_than_30) do
        build(:exchange_participant,
          birthdate: 30.years.ago - 1.day,
          registerable: build(:gv_participant))
      end
      let(:youth) do
        build(:exchange_participant, registerable: build(:gv_participant))
      end

      it { expect(younger_than_18).not_to be_valid }

      it { expect(older_than_30).not_to be_valid }

      it { expect(youth).to be_valid }
    end
  end
end
