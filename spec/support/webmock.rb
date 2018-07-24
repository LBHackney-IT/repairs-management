require 'webmock/rspec'
WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: %{neo4j_db_test}
})
