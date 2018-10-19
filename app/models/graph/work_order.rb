class Graph::WorkOrder
  include Neo4j::ActiveNode
  MAX_RELATIONS = 1..6

  id_property :reference

  property :property_reference, type: String
  property :created, type: DateTime
  property :source, type: String

  has_many :both, :cited_work_orders, rel_class: 'Graph::Citation'

  def related
    cited_work_orders(rel_length: MAX_RELATIONS).to_a.uniq - [self]
  end
end
