class Graph::WorkOrder
  include Neo4j::ActiveNode

  id_property :reference

  property :property_reference, type: String
  property :created, type: DateTime
  property :source, type: String

  has_many :both, :cited_work_orders, rel_class: 'Graph::Citation'

  def related
    cited_work_orders(rel_length: :any).to_a.uniq - [self]
  end
end
