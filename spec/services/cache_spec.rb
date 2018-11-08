require 'rails_helper'

describe Cache do
  it 'returns a cached value' do
    api = double
    expect(api).to receive(:fetch).once { 'woo!' }

    cache = Cache.new { |k| api.fetch(k) }

    expect(cache['a']).to eq 'woo!'
    expect(cache['a']).to eq 'woo!'
  end

  it 'returns seeded values' do
    api = double
    expect(api).to receive(:fetch).never

    cache = Cache.new('b' => 'boo!') { |k| api.fetch(k) }

    expect(cache['b']).to eq 'boo!'
  end
end
