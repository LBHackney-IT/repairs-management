class Hackney::CautionaryContact
  include ActiveModel::Model

  attr_accessor :alert_codes, :caller_notes

  def self.find_by_property_reference(property_reference)
    response = HackneyAPI::RepairsClient.new.get_cautionary_contact_by_property_reference(property_reference)
    new(attributes_from_api(response))
  end

  def self.attributes_from_api(attributes)
    {
      # FIXME: hack that normalizes Strings into Arrays
      alert_codes: [attributes["results"]["alertCodes"]].flatten.select(&:present?),
      caller_notes: [attributes["results"]["callerNotes"]].flatten.select(&:present?)
    }
  end
end
