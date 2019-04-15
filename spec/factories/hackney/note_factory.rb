FactoryBot.define do
  factory :hackney_note, class: Hackney::Note do
    sequence(:note_id)
    sequence(:text) { |i| "Note text #{i}" }
    logged_at { Time.current }
    logged_by { 'javaize' }
    work_order_reference { '01234567' }

    trait :servitor do
      logged_by { 'Servitor' }
    end
  end
end
