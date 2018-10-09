class Hackney::Report
  include ActiveModel::Model

  attr_accessor :mobile_reports

  def self.build(attributes)
    new(
      mobile_reports: attributes['mobileReports']
    )
  end

  def self.for_work_order_reports(reference)
    response = HackneyAPI::RepairsClient.new.get_work_order_reports(reference)
    build(response)
  end
end
