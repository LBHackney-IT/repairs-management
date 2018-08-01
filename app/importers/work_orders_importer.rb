class WorkOrdersImporter
  def initialize
    @client = HackneyRepairsClient.new
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
    @client.get('/v1/workorders')
  end
end
