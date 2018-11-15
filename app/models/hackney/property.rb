class Hackney::Property
  include ActiveModel::Model

  attr_accessor :reference, :level_code, :description, :major_reference, :address, :postcode

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
    # TODO: remove strip from attributes['attr'].strip - API should be fixed soon
    new(
      reference: attributes['propertyReference']&.strip,
      level_code: attributes['levelCode'],
      description: attributes['description']&.strip,
      major_reference: attributes['majorReference']&.strip,
      address: attributes['address']&.strip,
      postcode: attributes['postcode']
    )
  end

  def hierarchy
    @_hierarchy ||= HackneyAPI::RepairsClient.new.get_property_hierarchy(reference).map do |attributes|
      Hackney::Property.build(attributes)
    end
  end

  def possibly_related(from:, to: )
    @_possibly_related ||= Hackney::WorkOrder.for_property_block_and_trade(
      property_reference: reference,
      trade: Hackney::Trades::PLUMBING,
      date_from: from.strftime("%d-%m-%Y"),
      date_to: to.strftime("%d-%m-%Y")
    )
  end

  def dwelling_work_orders_hierarchy(years_ago)
    Hackney::WorkOrders::AssociatedWithProperty.new(self).call(years_ago)
  end

  def is_estate?
    hierarchy.map(&:description) - ['Owner'] == ['Estate']
  end
end
