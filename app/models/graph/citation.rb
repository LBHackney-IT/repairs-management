class Graph::Citation
  include Neo4j::ActiveRel

  from_class 'Graph::WorkOrder'
  to_class 'Graph::WorkOrder'

  property :note_id, type: Integer
  property :work_order_reference, type: String
  property :source, type: String
  property :extra, type: Boolean

  def self.cite_by_note!(from:, to:, note_id:, source:)
    Graph::Citation.create!(from_node: from, to_node: to,
                            note_id: note_id,
                            extra: from.related.include?(to),
                            source: source)
  end

  def self.cite_by_work_order!(from:, to:, source:)
    Graph::Citation.create!(from_node: from, to_node: to,
                            work_order_reference: from.reference,
                            extra: from.related.include?(to),
                            source: source)
  end

end
