class Hackney::Keyfax
  include ActiveModel::Model

  attr_accessor :launch_url, :guid

  def self.get_startup_url
    response = HackneyAPI::RepairsClient.new.get_keyfax_url
    new_from_api(response.dig("body", "startupResult"))
  end

  def self.new_from_api(attributes)
    new(attributes_from_api(attributes))
  end

  def self.attributes_from_api(attributes)
    {
      launch_url: attributes['launchUrl'],
      guid: attributes['guid']
    }
  end
end
