FactoryBot.define do
  factory :graph_note, class: 'Graph::Note' do
    sequence(:note_id) { |i|  i }
    sequence(:work_order_reference) { |i| "%08d" % i }
    logged_at { Time.current }
    source { 'test' }
  end
end
