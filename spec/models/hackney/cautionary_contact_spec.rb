require 'rails_helper'

describe Hackney::CautionaryContact do
  include Helpers::HackneyRepairsRequestStubs

  describe '.attributes_from_api' do
    it 'maps fields correctly' do
      h = Hackney::CautionaryContact.attributes_from_api({
        "contactAlerts": [
          {
            "alertCode": "VA",
            "alertDescription": "Verbal Abuse or Threat of"
          },
          {
            "alertCode": "CV",
            "alertDescription": "No Lone Visits"
          }
        ],
        "addressAlerts": [
          {
            "alertCode": "DIS",
            "alertDescription": "Property under Disrepair"
          }
        ],
        "callerNotes": [
          "Do not attend, bad singing"
        ]
      }.with_indifferent_access)

      expect(h).to eq({
        address_alerts: [
          Hackney::CautionaryContact::Alert.new("DIS", "Property under Disrepair")
        ],
        contact_alerts: [
          Hackney::CautionaryContact::Alert.new("VA", "Verbal Abuse or Threat of"),
          Hackney::CautionaryContact::Alert.new("CV", "No Lone Visits")
        ],
        caller_notes: [
          "Do not attend, bad singing"
        ]
      })
    end
  end
end
