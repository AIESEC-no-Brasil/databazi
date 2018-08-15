require 'rails_helper'

RSpec.describe ExchangeParticipantsController, type: :controller do
  describe '#validate_email' do
    subject(:do_validate_email) do
      get :validate_email, params: { email: 'test@example.com' }
    end

    let(:response) { JSON.parse(subject.body)['email_exists'] }

    context 'when given email exists in databazi' do
      before do
        create(:exchange_participant,
               registerable: build(:gv_participant), email: 'test@example.com')
      end

      it 'returns true for email_exists' do
        expect(response).to eq true
      end
    end

    context 'when given email exists in bazicon' do
      before do
        allow(controller).to receive(:bazicon_email_validation)
          .and_return(true)
      end

      it 'returns true for email_exists' do
        expect(response).to eq true
      end

      it 'calls for bazicon_email_validation' do
        do_validate_email

        expect(controller).to have_received(:bazicon_email_validation)
      end
    end

    context 'when given email doesn\'t exist in either applications' do
      before do
        allow(controller).to receive(:bazicon_email_validation)
          .and_return(false)
      end

      it 'returns false for email_exists' do
        expect(response).to eq false
      end

      it 'calls for bazicon_email_validation' do
        do_validate_email

        expect(controller).to have_received(:bazicon_email_validation)
      end
    end
  end
end
