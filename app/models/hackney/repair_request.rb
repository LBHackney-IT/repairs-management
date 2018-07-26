require './lib/hackney_repairs_client'

class Hackney::RepairRequest
  class RecordNotFound < StandardError; end
  class Error < StandardError; end

  attr_accessor :reference, :description

  def initialize(reference)
    @client = HackneyRepairsClient.new
    @reference = reference
  end

  def build
    make_request
    check_response
    assign_attributes
    self
  end

  private

  def make_request
    @response = @client.connection.get("/v1/repairs/#{@reference}")
  end

  def check_response
    case @response.status
    when 200
      @resource = @response.body
    when 404
      raise RecordNotFound.new
    else
      raise Error.new
    end
  end

  def assign_attributes
    self.reference = @resource['repairRequestReference']
    self.description = @resource['problemDescription']
  end
end
