class WorkOrderPage
  attr_reader :work_order, :repair_request, :property

  def initialize(work_order_reference)
    @work_order = Hackney::WorkOrder.new(work_order_reference).build
    @repair_request = Hackney::RepairRequest.new(repair_request_reference).build
    @property = Hackney::Property.new(property_reference).build
  end

  private

  def repair_request_reference
    @work_order.rq_ref
  end

  def property_reference
    @work_order.prop_ref
  end
end
