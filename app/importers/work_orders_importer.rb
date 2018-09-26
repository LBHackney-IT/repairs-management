require 'csv'

class WorkOrdersImporter
  def import_notes
    read_csv('note') do |row|
      import_note(
        row['NoteId'],
        row['WorkOrderReference'],
        row['LoggedAt'],
        row['Text']
      )
    end
  end

  def import_work_orders
    read_csv('work order') do |row|
      import_work_order(
        row['wo_ref'],
        row['prop_ref'],
        row['created'],
        row['rq_problem']
      )
    end
  end

  private

  def read_csv(kind)
    count = 0
    time = Time.current
    CSV.parse(STDIN, headers: true) do |row|
      yield row
      count += 1
      if count % 100 == 0
        puts "count = %d, %0.5f s per %s" % [count, (Time.current - time) / 100, kind]
        time = Time.current
      end
    end
  end

  def import_work_order(work_order_ref, property_ref, created, text)
    Neo4j::ActiveBase.run_transaction do
      return if Graph::WorkOrder.find_by(reference: work_order_ref).present?

      numbers = Hackney::WorkOrders::ReferenceFinder.new(work_order_ref).find(text)
      work_order = Graph::WorkOrder.create!(reference: work_order_ref,
                                            property_reference: property_ref,
                                            created: created)

      numbers.each do |number|
        linked = Graph::WorkOrder.find_by(reference: number)
        if linked
          Graph::Citation.create!(from_node: work_order, to_node: linked,
                                  work_order_reference: work_order_ref)
        end
      end
    end
  end

  def import_note(note_id, work_order_ref, logged_at, text)
    numbers = Hackney::WorkOrders::ReferenceFinder.new(work_order_ref).find(text)
    RelatedWorkOrderJob.new.perform(note_id, logged_at, work_order_ref, numbers)
  end
end
