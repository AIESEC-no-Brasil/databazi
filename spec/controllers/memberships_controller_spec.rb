require 'rails_helper'

RSpec.describe MembershipsController, type: :controller do

  describe "POST #create" do
    it "returns http success" do
      post :create, params: { membership: attributes_for(:membership) }

      expect(response).to have_http_status(:success)
    end
  end

end
