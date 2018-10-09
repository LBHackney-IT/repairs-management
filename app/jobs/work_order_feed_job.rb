# WorkOrders must be imported in sequence, this is because work orders can
# relate to other work orders in the past. If we were to have a situation where
# the import fails for 1 WorkOrder we would want all subsequent ones to stop.
class WorkOrderFeedJob < ApplicationJob
  queue_as :feed

  ENQUEUE_LIMIT = 50

  def perform(enqueues, max_enqueues)
    work_orders = Hackney::WorkOrder.feed(Graph::WorkOrder.last_imported)

    importer = GraphModelImporter.new(self.class.source_name)

    work_orders.each do |work_order|
      numbers = extract_references(work_order)
      importer.import_work_order(work_order_ref: work_order.reference,
                                 property_ref: work_order.prop_ref,
                                 created: work_order.created,
                                 target_numbers: numbers)
    end

    if enqueues < max_enqueues && work_orders.size >= ENQUEUE_LIMIT
      perform(enqueues + 1, max_enqueues)
    end
  end

  private

  def self.source_name
    self.name
  end

  def extract_references(work_order)
    WorkOrderReferenceFinder
      .new(work_order.reference)
      .find(work_order.problem_description)
      .select { |n| n < work_order.reference } # work orders can only refer to previous work orders
  end

end
