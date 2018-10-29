class Graph::WorkOrder
  include Neo4j::ActiveNode
  MAX_RELATIONS = 20

  id_property :reference

  property :property_reference, type: String
  property :created, type: DateTime
  property :source, type: String

  validates :property_reference, :created, :source, presence: true

  has_many :both, :cited_work_orders, rel_class: 'Graph::Citation'

  def related
    query_as(:s)
      .match("(s)-[*..#{MAX_RELATIONS} {extra: false}]-(p)")
      .pluck(:p)
      .to_a.uniq - [self]
  end

  def citations_for(work_order)
    citations = []
    cited_work_orders.where(reference: work_order.reference).each_rel do |r|
      citations << r
    end
    citations
  end
end
