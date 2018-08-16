class Hackney::Note
  include ActiveModel::Model

  attr_accessor :text, :logged_at, :logged_by

  def self.build(attributes)
    new(
      text: attributes['noteText'],
      logged_at: attributes['nDate'].to_datetime,
      logged_by: attributes['userID']
    )
  end
end
