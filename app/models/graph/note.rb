class Graph::Note
  include Neo4j::ActiveNode

  id_property :note_id

  property :logged_at, type: DateTime
  property :source, type: String
  property :work_order_reference, type: String
end
