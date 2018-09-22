class RelatedWorkOrderJob < ApplicationJob
  queue_as :default

  def perform(note_id, logged_at, work_order_reference, target_numbers)
    return if Graph::Note.exists?(note_id: note_id)

    within_transaction do
      work_order = create_graph_models(note_id, logged_at, work_order_reference)
      target_numbers.each do |target_number|
        create_citations(work_order, note_id, target_number)
      end
    end
  end

  private

  def create_graph_models(note_id, logged_at, work_order_reference)
    note = Graph::Note.create(note_id: note_id,
                              logged_at: logged_at)

    work_order = find_or_create_graph_work_order(work_order_reference)

    work_order.notes << note
    work_order
  end

  def create_citations(graph_work_order, note_id, target_number)
    target = find_or_create_graph_work_order(target_number)

    Graph::Citation.create(from_node: graph_work_order, to_node: target,
                           note_id: note_id)

  rescue HackneyAPI::RepairsClient::RecordNotFoundError
    nil # this is fine, target_numbers are not guaranteed to be work orders
  end

  def find_or_create_graph_work_order(work_order_reference)
    Graph::WorkOrder.find_by(reference: work_order_reference) ||
      create_work_order(work_order_reference)
  end

  def create_work_order(work_order_reference)
    candidate = Hackney::WorkOrder.find(work_order_reference)
    Graph::WorkOrder.create(reference: work_order_reference,
                            property_reference: candidate.prop_ref,
                            created: candidate.created)
  end

  def within_transaction
    Neo4j::ActiveBase.run_transaction do
      yield
    end
  end
end
