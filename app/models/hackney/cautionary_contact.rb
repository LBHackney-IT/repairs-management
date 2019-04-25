class Hackney::CautionaryContact
  include ActiveModel::Model

  attr_accessor :property_reference, :contact_number, :title, :forename, :surname, :caller_notes, :alert_code

  def self.find(property_reference)
    response = HackneyAPI::RepairsClient.new.get_cautionary_contact(property_reference)
    if response['results'].any?
      build(response['results'].first)
    else
      nil
    end
  end

  def self.build(attributes)
    new(
      property_reference: attributes['propertyReference'],
      contact_number: attributes['contactNo'],
      title: attributes['title'],
      forename: attributes['forenames'],
      surname: attributes['surename'],
      caller_notes: attributes['callerNotes'],
      alert_code: attributes['alertCode']
    )
  end
end
