class Graph::Note
  include Neo4j::ActiveNode

  id_property :note_id

  property :logged_at, type: DateTime
  property :source, type: String


  has_one :out, :work_order, type: :note_work_order, model_class: 'Graph::WorkOrder'
end
