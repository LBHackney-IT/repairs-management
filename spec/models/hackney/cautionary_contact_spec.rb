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
          {
            "uhUserName": "PPUDDING",
            "uhUserFullName": "Pudding Pudding",
            "noteText": "**Do not attend, bad singing**",
            "dateCreated": "2006-06-06T06:06:06"
          }
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
          Hackney::CautionaryContact::CallerNote.new("PPUDDING", "Pudding Pudding", "**Do not attend, bad singing**", "2006-06-06T06:06:06")
        ]
      })
    end
  end
end
