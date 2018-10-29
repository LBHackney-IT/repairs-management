class ForceCreateGraphLastFromFeedFeedTypeConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :"Graph::LastFromFeed", :feed_type, force: true
  end

  def down
    drop_constraint :"Graph::LastFromFeed", :feed_type
  end
end
