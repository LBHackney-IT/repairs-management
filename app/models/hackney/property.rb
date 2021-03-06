class Hackney::Property
  include ActiveModel::Model

  ESTATE_LEVEL = 2

  RAISABLE_TENURES = %w(ASY COM DEC INT MPA NON PVG SEC TAF TGA TRA)

  attr_accessor :reference, :level_code, :description, :major_reference, :address,
                :postcode, :tenure, :tenure_code, :letting_area

  attr_accessor :property_type_code, :property_type_description

  attr_accessor :tenancy_agreement_reference

  def self.find(property_reference)
    response = HackneyAPI::RepairsClient.new.get_property(property_reference)
    build(response)
  end

  def self.find_all(references)
    if references.any?
      response = HackneyAPI::RepairsClient.new.get_properties_by_references(references)
      response.map { |r| build(r) }
    else
      []
    end
  rescue HackneyAPI::RepairsClient::RecordNotFoundError => e
    Rails.logger.error(e)
    Appsignal.set_error(e, message: "Properties not found")
    []
  end

  def self.for_postcode(postcode)
    HackneyAPI::RepairsClient.new.get_property_by_postcode(postcode)["results"].map do |attributes|
      build(attributes)
    end
  end

  def self.for_address(address, limit:)
    HackneyAPI::RepairsClient.new.get_property_by_address(address, limit: limit)["results"].map do |attributes|
      build(attributes)
    end
  end

  def self.facilities_for_property_reference(reference)
    r = HackneyAPI::RepairsClient.new.get_facilities_by_property_reference(reference)
    r["results"].map {|x| build(x) }
  end

  def self.build(attributes)
    # TODO: remove strip from attributes['attr'].strip - API should be fixed soon
    new(
      reference: attributes['propertyReference']&.strip,
      level_code: attributes['levelCode'],
      description: attributes['description']&.strip,
      major_reference: attributes['majorReference']&.strip,
      address: attributes['address']&.strip,
      postcode: attributes['postcode'],
      tenure: attributes['tenure'],
      tenure_code: attributes['tenureCode'],
      letting_area: attributes['lettingArea'],
      property_type_code: attributes['propertyTypeCode'],
      property_type_description: attributes['propertyTypeDescription'],
      tenancy_agreement_reference: attributes['tenancyAgreementReference'],
    )
  end

  def hierarchy
    @_hierarchy ||= HackneyAPI::RepairsClient.new.get_property_hierarchy(reference).map do |attributes|
      Hackney::Property.build(attributes)
    end
  end

  def facilities
    @_facilities ||= self.class.facilities_for_property_reference(reference)
  end

  def possibly_related(from:, to:)
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
    level_code == ESTATE_LEVEL
  end

  def can_raise_a_repair?
    tenure_code.blank? || RAISABLE_TENURES.include?(tenure_code)
  end

  def is_tmo?
    letting_area.to_s.downcase.include? "tmo"
  end

  def new_build?
    property_type_code == 'NBD'
  end

  def first_line_of_address
    address.match?(/\s\s/) ? address[/.+(?<=\s{2})/] : address
  end
end
