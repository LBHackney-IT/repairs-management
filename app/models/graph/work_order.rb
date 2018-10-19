class Graph::WorkOrder
  include Neo4j::ActiveNode
  MAX_RELATIONS = 1..6

  id_property :reference

  property :property_reference, type: String
  property :created, type: DateTime
  property :source, type: String

  has_many :both, :cited_work_orders, rel_class: 'Graph::Citation'

  FIRST_REFERENCE = "00000000".freeze

  def related
    cited_work_orders(rel_length: MAX_RELATIONS).to_a.uniq - [self]
  end

  def self.last_imported
    ordered_sources = [GraphModelImporter::WORK_ORDERS_IMPORT, WorkOrderFeedJob.source_name]
    where(source: ordered_sources, reference: /^\d{8}$/).last&.reference || FIRST_REFERENCE
  end
end
