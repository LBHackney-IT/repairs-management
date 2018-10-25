FactoryBot.define do
  factory :property, class: 'Hackney::Property' do
    sequence(:reference) { |i| "R#{i}" }
    level_code { '1' }
    description { 'description' }
    sequence(:major_reference) { |i| "MR#{i}" }
    address { 'Address' }
    postcode { 'Postcode' }
  end
end
