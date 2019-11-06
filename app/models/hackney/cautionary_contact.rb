class Hackney::CautionaryContact
  include ActiveModel::Model
  Alert = Struct.new(:code, :description)

  attr_accessor :address_alerts
  attr_accessor :contact_alerts
  attr_accessor :caller_notes

  def self.find_by_property_reference(property_reference)
    response = HackneyAPI::RepairsClient.new.get_cautionary_contact_by_property_reference(property_reference)
    new(attributes_from_api(response))
  end

  def self.attributes_from_api(attributes)


    {
      address_alerts: safe_map_array(attributes["addressAlerts"]) {|x| Alert.new(x["alertCode"], x["alertDescription"]) },
      contact_alerts: safe_map_array(attributes["contactAlerts"]) {|x| Alert.new(x["alertCode"], x["alertDescription"]) },
      caller_notes: [attributes["callerNotes"]].flatten.compact,
    }
  end

  private

  def self.safe_map_array(a, &b)
    [a].flatten.compact.map(&b)
  end
end
