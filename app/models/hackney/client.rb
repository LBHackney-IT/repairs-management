module Hackney::Client
  extend ActiveSupport::Concern

  class_methods do
    def client
      HackneyAPI::RepairsClient.new
    end
  end
end
