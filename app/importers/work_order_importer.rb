require './lib/hackney_repairs_client'

class WorkOrderImporter
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
    response.body.fetch('data')
  end

  def response
    @client.connection.get('/v1/workorders')
  end
end
