class HackneyRepairsClient
  class RecordNotFound < StandardError; end
  class Error < StandardError; end

  def initialize(opts = {})
    @base_url = opts.fetch(:base_url) { ENV.fetch('HACKNEY_REPAIRS_API_BASE_URL') }
  end

  def get_work_order(reference)
    get("v1/workorders/#{reference}")
  end

  def get_repair_request(reference)
    get("v1/repairs/#{reference}")
  end

  def get_property(reference)
    get("v1/properties/#{reference}")
  end

  def get_work_order_notes(reference)
    get("v1/workorders/#{reference}/notes")
  end

  def get(endpoint)
    response = connection.get(endpoint)
  rescue => error
    raise Error, "#{error} #{error.message}, caused by #{error.cause}"
  else
    case response.status
    when 200
      return response.body
    when 404
      raise RecordNotFound, endpoint
    else
      raise Error, [endpoint, response.status, response.body].join(', ')
    end
  end

  private

  def connection
    @_connection ||= Faraday.new(@base_url) do |faraday|
      faraday.proxy = ENV['QUOTAGUARDSTATIC_URL']
      faraday.response :json
      faraday.response :logger unless Rails.env.test?
      faraday.adapter :net_http
    end
  end
end
