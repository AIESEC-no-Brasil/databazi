require 'rails_helper'

RSpec.describe ExpaApplicationSync do
  subject { ExpaApplicationSync.new }
  
  it { is_expected.to respond_to(:call) }

  it 'fetchs access token' do
    allow_any_instance_of(ExpaApplicationSync).to receive(:access_token)
    subject.call

    expect(subject).to have_received(:access_token)
  end

  it 'fetchs application page' do
    allow_any_instance_of(ExpaApplicationSync).to receive(:load_applications)
    subject.call

    expect(subject).to have_received(:load_applications)
  end
  # 0 - Get API Token
  # 1 - Load Eps and get Application
  # 2 - Load all applications GQ e atualizar

  describe '#methods' do
    context 'access_token' do
      context 'success' do
        it 'is expected to return a non nil token' do
          expect(subject.send(:access_token)).not_to be_empty
        end
      end

      context 'failure' do
        it 'is expected to return error' do
          allow(subject).to receive(:token_token).and_return('borigodofa')
          expect{subject.send(:access_token)}.to raise_exception(RuntimeError)
        end
      end
    end

    context 'token_token' do
      it { expect(subject.send(:token_token)).to eq ENV['API_AUTHENTICITY_TOKEN'] }
    end

    context 'load_applications', :focus => true do
      context 'success' do
        it 'is expected to return a list of applications' do
          expect(subject.send(:load_applications)).to be_an_instance_of(Array)
        end
        it 'is expected to return a list of applications' do
          expect(subject.send(:load_applications)).to be_an_instance_of(Array)
        end
      end
    end
  end
end
