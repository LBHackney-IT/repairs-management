class WorkOrdersImporter
  def import
    work_orders.each do |wo|
      WorkOrder.find_or_create_by(ref: wo['id'])
    end
  end

  private

  def work_orders
    response.fetch('data')
  end

  def api_client
    @_api_client ||= HackneyAPI::RepairsClient.new
  end

  def response
    api_client.get_work_orders
  end
end
