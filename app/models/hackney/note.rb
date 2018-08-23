class Hackney::Note
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :text, :logged_at, :logged_by

  def self.build(attributes)
    new(
      text: attributes['text'],
      logged_at: attributes['loggedAt'].to_datetime,
      logged_by: attributes['loggedBy']
    )
  end

  def self.for_work_order(work_order_reference)
    client.get_work_order_notes(work_order_reference)
      .map { |attributes| Hackney::Note.build(attributes) }
  rescue HackneyAPI::RepairsClient::ApiError
    [] # The API currently returns 500 for notes... so patch it like this until the API is working
  end
end
