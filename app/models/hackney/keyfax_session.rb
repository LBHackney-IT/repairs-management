class Hackney::KeyfaxSession
  include ActiveModel::Model

  attr_accessor :launch_url, :guid

  def self.get_startup_url(current_page_url)
    response = HackneyAPI::RepairsClient.new.get_keyfax_url(current_page_url)
    new_from_api_for_url(response.dig("body", "startupResult"))
  end

  def self.new_from_api_for_url(attributes)
    new(attributes_from_api_for_url(attributes))
  end

  def self.attributes_from_api_for_url(attributes)
    {
      launch_url: attributes['launchUrl'],
      guid: attributes['guid']
    }
  end
end
