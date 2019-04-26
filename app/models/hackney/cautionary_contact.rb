class Hackney::CautionaryContact
  include ActiveModel::Model

  attr_accessor :property_reference, :contact_number, :title, :forename, :surname, :caller_notes, :alert_code

  def self.find_by_property_reference(property_reference)
    response = HackneyAPI::RepairsClient.new.get_cautionary_contact_by_property_reference(property_reference)
    response["results"].map do |attributes|
      Hackney::CautionaryContact.build(attributes)
    end
  end

  def self.build(attributes)
    new(attributes_from_api(attributes))
  end

  def self.attributes_from_api(attributes)
    {
      property_reference: attributes['propertyReference'],
      contact_number: attributes['contactNo'],
      title: attributes['title'],
      forename: attributes['forenames'],
      surname: attributes['surename'],
      caller_notes: attributes['callerNotes'],
      alert_code: attributes['alertCode']
    }
  end
end
