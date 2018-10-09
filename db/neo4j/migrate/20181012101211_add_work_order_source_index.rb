class AddWorkOrderSourceIndex < Neo4j::Migrations::Base
  def up
    add_index(:"Graph::WorkOrder", :source)
  end

  def down
    drop_index(:"Graph::WorkOrder", :source)
  end
end
