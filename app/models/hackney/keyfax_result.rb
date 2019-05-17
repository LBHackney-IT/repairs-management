class Hackney::KeyfaxResult
  include ActiveModel::Model

  attr_accessor :fault_text, :sor_code, :problem_description, :priority

  def self.get_response(guid)
    response = HackneyAPI::RepairsClient.new.get_keyfax_result(guid)
    new_from_api_for_response(response)
  end

  def self.new_from_api_for_response(attributes)
    new(attributes_from_api_for_result(attributes))
  end

  def self.attributes_from_api_for_result(attributes)
    {
      fault_text: attributes['faultText'],
      sor_code: attributes['repairCode'],
      problem_description: attributes['repairCodeDesc'],
      priority: attributes['priority']
    }
  end
end
