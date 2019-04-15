class WorkOrderReferenceFinder
  def initialize(work_order_reference)
    @work_order_reference = work_order_reference
  end

  def find(text)
    text.scan(/\d+/).select { |n| n.size == 8 && n != @work_order_reference }
  end

  def find_in_note(hackney_note)
    text = hackney_note.text || ''
    text = strip_servitor_job_refs(text, hackney_note.logged_by)
    find(text)
  end
  
  private
  
  def strip_servitor_job_refs(text, logged_by)
    if logged_by == 'Servitor'
      text.gsub(/JOB-\d{8}/, '')
    else
      text
    end
  end
end
