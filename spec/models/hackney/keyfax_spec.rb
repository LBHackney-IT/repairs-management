require 'rails_helper'

describe Hackney::Keyfax do
  include Helpers::HackneyRepairsRequestStubs

  describe '.get_startup_url' do
    it 'gets a url' do
      stub_keyfax_get_startup_url

      keyfax_instance = described_class.get_startup_url("https://repairs-hub.hackney.gov.uk/properties/00004769/repair_requests/new")

      expect(keyfax_instance).to be_a(Hackney::Keyfax)
    end
  end

  # describe '.get_response' do
  #   it 'returns a response' do
  #     response = described_class.get_response('e7ed9140-8516-40fe-b99a-cb6d7c32d66e')
  #
  #     expect(response).to be_a(Hackney::Keyfax)
  #   end
  #
  #   context 'when the API fails' do
  #     it 'raises an api error' do
  #       expect {
  #         described_class.get_response('e7ed9140-8516-40fe-b99a-cb6d7c32d66e')
  #       }.to raise_error HackneyAPI::RepairsClient::ApiError
  #     end
  #   end
  # end
end
