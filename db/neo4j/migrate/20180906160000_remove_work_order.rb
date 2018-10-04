class RemoveWorkOrder < Neo4j::Migrations::Base
  def up
    drop_constraint :WorkOrder, :ref
  end

  def down
    add_constraint :WorkOrder, :ref
  end
end
