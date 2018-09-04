module WorkOrderHelper
  def work_order_status_description(work_order_status)
   {
     '100' => 'Collated',
     '200' => 'In Progress',
     '300' => 'Work Complete',
     '350' => 'Work Defective',
     '400' => 'Hold',
     '425' => 'Variation Outstanding',
     '450' => 'In Dispute',
     '500' => 'Approved for Statement',
     '600' => 'Statemented',
     '700' => 'Cancel Order',
     '900' => 'Complete'
   }[work_order_status]
  end

  def dlo_status_description(dlo_status)
   {
     '0' => 'Gone to Servitor',
     '1' => 'DLO Acknowledged',
     '2' => 'Job Ticket Printed',
     '3' => 'Completed',
     '6' => 'Cancelled',
     '8' => 'On Hold (i.e. Awaiting Authorisation, No Access, Awaiting Materials etc)',
     'F' => 'Off Hold'
   }[dlo_status]
  end
end
