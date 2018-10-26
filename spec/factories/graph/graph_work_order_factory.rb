FactoryBot.define do
  factory :graph_work_order, class: 'Graph::WorkOrder' do
    sequence(:reference) { |i| "%08d" % i }
    sequence(:property_reference) { |i| "%08d" % i }
    created { Time.current }
    source { 'test' }
  end
end
