FactoryBot.define do
  factory :property_hierarchy, class: 'Hackney::PropertyHierarchy' do
    sequence(:reference) { |i| "R#{i}" }
    level_code { '1' }
    description { 'description' }
    sequence(:major_reference) { |i| "MR#{i}" }
    address { 'Address' }
    postcode { 'Postcode' }
  end
end
