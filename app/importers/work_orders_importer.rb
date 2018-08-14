class WorkOrdersImporter
  def initialize
    @client = HackneyAPI::RepairsClient.new
  end

  def import
    work_orders.each do |wo|
      WorkOrder.find_or_create_by(ref: wo['id'])
    end
  end

  private

  def work_orders
    response.fetch('data')
  end

  def response
    @client.request(
      http_method: :get,
      endpoint: '/v1/workorders'
    )
  end
end
