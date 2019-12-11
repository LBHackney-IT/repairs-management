require 'rails_helper'

describe Tenancy::Contact do
  describe "api calls" do
    describe ".find" do
      it "works" do
        stub = stub_request(:get, "#{ ENV['TENANCY_API_URL'] }/tenancies/000006%252F66/contacts").to_return(
          status: 200,
          body: [].to_json
        )
        Tenancy::Contact.all(params: {tenancy_id: CGI.escape("000006/66")})
        expect(stub).to have_been_requested
      end
    end
  end
end
