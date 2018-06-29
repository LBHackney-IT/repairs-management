require 'rails_helper'

RSpec.describe "Stuffs", type: :request do
  describe "GET /stuffs" do
    it "works! (now write some real specs)" do
      get stuffs_path
      expect(response).to have_http_status(200)
    end
  end
end
