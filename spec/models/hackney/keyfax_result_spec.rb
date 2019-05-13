require 'rails_helper'

describe Hackney::KeyfaxResult do

  def keyfax_results_response_body
      {
        "faultText" => "Electric lighting: Communal; Block Lighting; 3; All lights out",
        "repairCode" => "20110120",
        "repairCodeDesc" => "LANDLORDS LIGHTING-FAULT",
        "priority" => "E"
      }
  end

  def stub_keyfax_get_results_response(guid: 'e7ed9140-8516-40fe-b99a-cb6d7c32d66e', status: 200,
                                                    body: keyfax_results_response_body)
    stub_request(:get, "https://hackneyrepairs/#{API_VERSION}/keyfax/kf_result/#{guid}")
      .to_return(status: status, body: body.to_json)
  end

  describe '.get_response' do
    it 'returns a response' do
      response = KeyfaxResult.get_response('e7ed9140-8516-40fe-b99a-cb6d7c32d66e')

      expect(response.fault_text).to eq('Electric lighting: Communal; Block Lighting; 3; All lights out')
      expect(response.sor_code).to eq('20110120')
      expect(response.description).to eq('LANDLORDS LIGHTING-FAULT')
      expect(response.priority).to eq('E')
    end
  end
end
