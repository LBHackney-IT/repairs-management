class Hackney::Appointment
  include ActiveModel::Model

  attr_accessor *%i(
    begin_date
    end_date
    target_date
    resource_name
    status
    priority
    data_source
  )

  def self.build(attributes)
    new(
      begin_date: attributes['beginDate'].strip.to_datetime,
      end_date: attributes['endDate'].strip.to_datetime,
      target_date: attributes['targetDate'].strip.to_datetime,
      resource_name: attributes['resourceName'].strip,
      status: attributes['status'].strip,
      priority: attributes['priority'].strip,
      data_source: attributes['dataSource']
    )
  end

  def out_of_target?
    target_date < end_date
  end
end
