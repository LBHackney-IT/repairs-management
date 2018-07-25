class WorkOrderPage
  attr_reader :work_order

  def initialize(work_order_reference)
    @work_order = Hackney::WorkOrder.new(work_order_reference).build
  end
end
