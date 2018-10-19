class Graph::Note
  include Neo4j::ActiveNode

  id_property :note_id

  property :logged_at, type: DateTime
  property :source, type: String
  property :work_order_reference, type: String

  FIRST_NOTE_ID = 1

  def self.last_note_id
    last_note = self.last
    last_note.nil? ? FIRST_NOTE_ID : last_note.note_id
  end
end
