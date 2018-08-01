RSpec.configure do |config|
  config.before(:example, :db_connection) do
    # Checks for pending migrations and applies them before tests are run.
    # If you are not using ActiveRecord, you can remove this line.
    ActiveRecord::Migration.maintain_test_schema!

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
  end

  config.before(:each, :db_connection) do
    # Make sure that no data exists in neo4j before the tests are ran
    Neo4j::ActiveBase.current_session.query(<<~CYPHER)
      MATCH (n) WHERE NOT n:`Neo4j::Migrations::SchemaMigration` DETACH DELETE n
    CYPHER
  end
end
