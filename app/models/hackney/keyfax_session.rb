class Hackney::KeyfaxSession
  include ActiveModel::Model

  attr_accessor :launch_url, :guid

  def self.create(current_page_url:)
    response = HackneyAPI::RepairsClient.new.get_keyfax_url(current_page_url)
    attributes = response.dig("body", "startupResult")

    new(
      launch_url: attributes['launchUrl'],
      guid: attributes['guid']
    )
  end
end
