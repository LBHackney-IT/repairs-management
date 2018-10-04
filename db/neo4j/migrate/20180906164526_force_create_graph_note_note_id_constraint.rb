class ForceCreateGraphNoteNoteIdConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :"Graph::Note", :note_id, force: true
  end

  def down
    drop_constraint :"Graph::Note", :note_id
  end
end
