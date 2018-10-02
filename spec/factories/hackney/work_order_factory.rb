FactoryBot.define do
  factory :work_order, class: 'Hackney::WorkOrder' do
    sequence(:reference) { |i| "R#{i}" }
    sequence(:rq_ref) { |i| "RQ#{i}" }
    sequence(:prop_ref) { |i| "P#{i}" }
    sequence(:servitor_reference) { |i| "SR#{i}" }

    created { DateTime.current - 1.week }
    date_due { DateTime.current + 1.week }

    work_order_status { '100' }
    dlo_status { '200' }
    problem_description { 'Desc' }
    trade { 'Plumbing' }
  end
end
