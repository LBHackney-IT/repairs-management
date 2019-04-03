class Graph::Note
  include Neo4j::ActiveNode
  include Profiling

  id_property :note_id

  property :logged_at, type: DateTime
  property :source, type: String
  property :work_order_reference, type: String

  validates :logged_at, :source, :work_order_reference, presence: true

  before_create do
    self.note_id = self.note_id.to_i
  end

  FIRST_NOTE_ID = 1
  LAST_NOTE_HACK = 9_000_000

  def self.last_note_id
    scope = self.query_as(:z).order("z.note_id DESC").limit(1)

    last_note = scope.where("z.note_id > #{LAST_NOTE_HACK}").pluck(:z).first
    last_note ||= scope.pluck(:z).first
    last_note.nil? ? FIRST_NOTE_ID : last_note.note_id
  end
end
