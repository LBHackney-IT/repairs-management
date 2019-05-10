class Hackney::Keyfax
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

  def self.get_response(guid)
    response = HackneyAPI::RepairsClient.new.get_keyfax_result(guid)
    # new_from_api_for_response(response.dig("body", "getResultsResult"))
  end

  def self.new_from_api_for_response(attributes)
    new(attributes_from_api_for_result(attributes))
  end

  def self.attributes_from_api_for_result(attributes)
    {
      launch_url: attributes['launchUrl'],
      guid: attributes['guid']
    }
  end
end
