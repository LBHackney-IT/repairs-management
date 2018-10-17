require 'webmock/rspec'
WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: %{neo4j_db_test}
})

WebMock::Config.instance.query_values_notation = :flat_array
