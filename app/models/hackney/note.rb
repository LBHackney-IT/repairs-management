class Hackney::Note
  include ActiveModel::Model

  attr_accessor :text, :logged_at, :logged_by

  def self.build(attributes)
    new(
      text: attributes['text'],
      logged_at: attributes['loggedAt'].to_datetime,
      logged_by: attributes['loggedBy']
    )
  end
end
