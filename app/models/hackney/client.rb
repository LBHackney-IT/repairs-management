module Hackney::Client
  extend ActiveSupport::Concern

  class_methods do
    def client
      @_client ||= ::HackneyAPI::RepairsClient.new
    end
  end
end
