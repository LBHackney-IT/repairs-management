class Hackney::Report
  include ActiveModel::Model

  attr_accessor :report_uri, :date

  def self.build(attributes)
    new(
      report_uri: attributes["reportUri"],
      date: attributes["date"]
    )
  end

  def self.for_work_order_reports(reference)
    HackneyAPI::RepairsClient.new.get_work_order_reports(reference)["mobileReports"].map do |attributes|
      build(attributes)
    end
  end
end
