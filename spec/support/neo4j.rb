RSpec.configure do |config|
  config.before(:each) do
    Neo4j::ActiveBase.current_session.query(<<~CYPHER)
      MATCH (n) WHERE NOT n:`Neo4j::Migrations::SchemaMigration` DETACH DELETE n
    CYPHER
  end
end
