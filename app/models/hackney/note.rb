class Hackney::Note
  include ActiveModel::Model

  attr_accessor :text, :logged_at, :logged_by, :note_id, :work_order_reference

  def self.build(attributes)
    new(
      text: attributes['text'],
      logged_at: attributes['loggedAt'].to_datetime,
      logged_by: attributes['loggedBy'],
      note_id: attributes['noteId'],
      work_order_reference: attributes['workOrderReference']
    )
  end

  def self.for_work_order(work_order_reference)
    HackneyAPI::RepairsClient.new.get_work_order_notes(work_order_reference)
      .map { |attributes| Hackney::Note.build(attributes) }
  end

  def self.feed(note_id, opts={})
    HackneyAPI::RepairsClient.new.notes_feed(note_id, opts).map { |attrs| Hackney::Note.build(attrs) }
  end

  def self.create_work_order_note(work_order_reference, text, created_by_email)
    HackneyAPI::RepairsClient.new.post_work_order_note(work_order_reference, text, created_by_email)
  end
end
