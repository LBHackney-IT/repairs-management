class Tenancy::Resource < ActiveResource::Base
  self.site = ENV["TENANCY_API_URL"]
  self.headers['X-API-KEY'] = "#{ENV['X_API_KEY']}" if ENV['X_API_KEY'].present?
  self.include_format_in_path = false

  # Handle collections inside objects
  class Collection < ActiveResource::Collection
    def initialize(jason = [])
      case jason
      when Hash
        data = jason["data"] || jason
        data.length == 1 or raise "More than one key in 'data'"
        @elements = data.values[0]
        @elements.is_a?(Array) or raise "Collection is not array"
      when Array
        @elements = jason
      else
        raise "Unexpected response format"
      end
    end
  end

  self.collection_parser = Collection
end
