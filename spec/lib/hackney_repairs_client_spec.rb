require './lib/hackney_repairs_client'

describe HackneyRepairsClient, '#connection' do
  it 'builds the full URL' do
    stub = stub_request(:get, 'https://example.com/foo/bar/baz').to_return(status: 200)

    client = HackneyRepairsClient.new(base_url: 'https://example.com/foo')
    client.connection.get('bar/baz')

    expect(stub).to have_been_requested
  end

  it 'replaces the subpath defined in base_url' do
    stub = stub_request(:get, 'https://example.com/bar/baz').to_return(status: 200)

    client = HackneyRepairsClient.new(base_url: 'https://example.com/foo')
    client.connection.get('/bar/baz')

    expect(stub).to have_been_requested
  end
end
