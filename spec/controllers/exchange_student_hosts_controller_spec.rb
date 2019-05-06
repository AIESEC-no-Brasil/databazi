require 'rails_helper'

RSpec.describe ExchangeStudentHostsController, type: :controller do
  let(:exchange_student_host) do
    build(:exchange_student_host,
          local_committee_id: create(:local_committee).id
    )
  end

  describe '#create', aws: true do
    subject(:do_create) { post :create, params: { exchange_student_host: host_params } }

    let(:host_params) do
      {
        fullname: exchange_student_host.fullname,
        email: exchange_student_host.email,
        cellphone: exchange_student_host.cellphone,
        zipcode: exchange_student_host.zipcode,
        neighborhood: exchange_student_host.neighborhood,
        city: exchange_student_host.city,
        state: exchange_student_host.state,
        local_committee_id: exchange_student_host.local_committee_id
      }
    end

    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }

    context 'when successful' do
      before do
        allow(ExchangeStudentHostWorker).to receive(:perform_async)
        allow(ExchangeStudentHostToPodio).to receive(:call)
      end

      it { expect { do_create }.to change(ExchangeStudentHost, :count).by 1 }

      it 'sends message to sqs' do
        do_create

        expect(ExchangeStudentHostWorker).to have_received(:perform_async)
      end
    end
  end
end
