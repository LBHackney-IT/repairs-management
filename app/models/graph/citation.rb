class Graph::Citation
  include Neo4j::ActiveRel

  from_class 'Graph::WorkOrder'
  to_class 'Graph::WorkOrder'

  property :note_id, type: Integer
  property :work_order_reference, type: String
  property :source, type: String
end
