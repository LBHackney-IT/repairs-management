require 'webmock/rspec'

allowed_sites = [
  "https://chromedriver.storage.googleapis.com",
  "https://github.com/mozilla/geckodriver/releases",
  "https://selenium-release.storage.googleapis.com",
  "https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver",
  %{neo4j_db_test}
]

WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: allowed_sites
})

WebMock::Config.instance.query_values_notation = :flat_array
