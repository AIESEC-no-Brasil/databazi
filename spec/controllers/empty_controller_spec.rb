require 'rails_helper'

RSpec.describe EmptyController, type: :controller do
  describe 'GET #index' do
    before { get :index }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns success message' do
      expect(response.body).to eq 'Success'
    end
  end
end
