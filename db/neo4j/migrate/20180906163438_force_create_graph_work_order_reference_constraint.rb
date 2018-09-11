class ForceCreateGraphWorkOrderReferenceConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :"Graph::WorkOrder", :reference, force: true
  end

  def down
    drop_constraint :"Graph::WorkOrder", :reference
  end
end
