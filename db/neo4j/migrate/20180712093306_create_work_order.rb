class CreateWorkOrder < Neo4j::Migrations::Base
  def up
    add_constraint :WorkOrder, :ref
  end

  def down
    drop_constraint :WorkOrder, :ref
  end
end
