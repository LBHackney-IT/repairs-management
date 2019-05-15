require 'rails_helper'

describe Hackney::KeyfaxSession do

  def keyfax_url_response_body
    {
      "body": {
        "startupResult":
          {
            "launchUrl" => "http://LBHKFXAPPT01/InterView/Main/Main.aspx?co=Hackney_Test&guid=6eb27594-18ca-4224-b95f-3afac7db0857",
            "guid" => "6f3ca92d-8171-42b3-bfb0-a135a47e604a",
          }
      }
    }
  end

  def stub_keyfax_get_startup_url(current_page_url: 'https://repairs-hub.hackney.gov.uk/properties/00004769/repair_requests/new', status: 200,
                                                    body: keyfax_url_response_body)
    stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/keyfax/get_startup_url/?returnurl=#{current_page_url}")
      .to_return(status: status, body: body.to_json)
  end

  describe '.get_startup_url' do
    it 'gets a url' do
      stub_keyfax_get_startup_url

      keyfax_instance = Hackney::KeyfaxSession.get_startup_url("https://repairs-hub.hackney.gov.uk/properties/00004769/repair_requests/new")

      expect(keyfax_instance).to be_a(Hackney::KeyfaxSession)
    end
  end
end
