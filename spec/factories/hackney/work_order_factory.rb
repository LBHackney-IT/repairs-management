FactoryBot.define do
  factory :hackney_work_order, class: Hackney::WorkOrder do
    sequence(:reference) { |i| '%08d'.format(i) }
    prop_ref { '1234' }
    created { Time.current }
  end
end
