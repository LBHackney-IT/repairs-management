class WorkOrder
  include Neo4j::ActiveNode

  id_property :ref
end
