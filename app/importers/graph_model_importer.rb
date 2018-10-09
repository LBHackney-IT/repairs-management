class GraphModelImporter

  WORK_ORDERS_IMPORT = 'work-orders-import'.freeze
  NOTES_IMPORT = 'notes-import'.freeze

  def initialize(source)
    @source = source
  end

  def import_work_order(work_order_ref:, property_ref:, created:, target_numbers:)
    within_transaction do
      return if Graph::WorkOrder.find_by(reference: work_order_ref).present?

      work_order = Graph::WorkOrder.create!(reference: work_order_ref,
                                            property_reference: property_ref,
                                            created: created,
                                            source: @source)

      target_numbers.each do |number|
        linked = Graph::WorkOrder.find_by(reference: number)
        if linked
          Graph::Citation.create!(from_node: work_order, to_node: linked,
                                  work_order_reference: work_order_ref,
                                  source: @source)
        end
      end

      work_order
    end
  end

  def import_note(note_id:, logged_at:, work_order_reference:, target_numbers:)
    within_transaction do
      return if Graph::Note.exists?(note_id: note_id)

      work_order = create_graph_models(note_id, logged_at, work_order_reference)
      target_numbers.each do |target_number|
        create_citations(work_order, note_id, target_number)
      end
    end
  end

  private

  def create_graph_models(note_id, logged_at, work_order_reference)
    Graph::Note.create!(note_id: note_id,
                        logged_at: logged_at,
                        source: @source,
                        work_order_reference: work_order_reference)

    find_or_create_graph_work_order(work_order_reference)
  end

  def create_citations(graph_work_order, note_id, target_number)
    # We assume that the work order import will have handled all work orders
    # up to a point and do not need to ask the API if a work order exists or not
    target = if target_number <= last_imported_work_order
               Graph::WorkOrder.find(target_number)
             else
               find_or_create_graph_work_order(target_number)
             end

    Graph::Citation.create!(from_node: graph_work_order, to_node: target,
                            note_id: note_id, source: @source)

  rescue HackneyAPI::RepairsClient::RecordNotFoundError, Neo4j::ActiveNode::Labels::RecordNotFound
    nil # this is fine, target_numbers are not guaranteed to be work orders
  end

  def last_imported_work_order
    @_last ||= Graph::WorkOrder.where(source: WORK_ORDERS_IMPORT).last&.reference || '00000000'
  end

  def find_or_create_graph_work_order(work_order_reference)
    Graph::WorkOrder.find_by(reference: work_order_reference) ||
      create_work_order(work_order_reference)
  end

  def create_work_order(work_order_reference)
    candidate = Hackney::WorkOrder.find(work_order_reference)
    numbers = WorkOrderReferenceFinder
                .new(work_order_reference)
                .find(candidate.problem_description)
    import_work_order(work_order_ref: work_order_reference,
                      property_ref: candidate.prop_ref,
                      created: candidate.created,
                      target_numbers: numbers)
  end

  def within_transaction
    Neo4j::ActiveBase.run_transaction do
      yield
    end
  end

end
