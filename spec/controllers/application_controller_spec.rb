require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#application_region' do
    context 'when variable is set' do
      before { allow(ENV).to receive(:[]).with('COUNTRY').and_return('arg') }

      it { expect(controller.application_region).to eq 'arg' }
    end

    context 'when nothing is set' do
      it { expect{ controller.application_region }.to raise_error KeyError }
    end
  end
end
