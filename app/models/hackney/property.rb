class Hackney::Property
  include ActiveModel::Model

  attr_accessor :reference, :address, :postcode

  def self.find(property_reference)
    response = HackneyAPI::RepairsClient.new.get_property(property_reference)
    build(response)
  end

  def self.for_postcode(postcode)
    HackneyAPI::RepairsClient.new.get_property_by_postcode(postcode)["results"].map do |attributes|
      build(attributes)
    end
  end

  def self.build(attributes)
    new(
      reference: attributes['propertyReference'].strip,
      address: attributes['address'],
      postcode: attributes['postcode']
    )
  end

  def work_orders
    @_work_orders ||= Hackney::WorkOrder.for_property(reference)
  end

  def work_orders_plumbing_from_block_and_last_two_weeks
    @_work_orders_plumbing_from_block_and_last_two_weeks ||= Hackney::WorkOrder.for_property_block_and_trade(
      property_reference: reference,
      trade: Hackney::Trades::PLUMBING,
      date_from: (Date.today - 2.weeks).strftime("%d-%m-%Y"),
      date_to: Date.today.strftime("%d-%m-%Y")
    )
  end

  def dwelling_work_orders_hierarchy
    @_dwelling_work_orders_hierarchy ||= Hackney::WorkOrders::AssociatedWithProperty.new(reference).call
  end

  def trades_hierarchy_work_orders
    @_trades ||= dwelling_work_orders_hierarchy.values.flatten.map(&:trade).uniq.sort
  end

  def is_estate?
    property_type = dwelling_work_orders_hierarchy.keys
    property_type == ['Estate']
  end
end
