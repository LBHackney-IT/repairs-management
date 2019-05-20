class Hackney::KeyfaxResult
  include ActiveModel::Model

  attr_accessor :fault_text, :sor_code, :problem_description, :priority

  def self.find(guid)
    response = HackneyAPI::RepairsClient.new.get_keyfax_result(guid)

    new(
      fault_text: response['faultText'],
      sor_code: response['repairCode'],
      problem_description: response['repairCodeDesc'],
      priority: response['priority']
    )
  end
end
