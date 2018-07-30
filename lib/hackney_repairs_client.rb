require 'faraday'
require 'faraday_middleware'

class HackneyRepairsClient
  def initialize(opts = {})
    @base_url = opts.fetch(:base_url) { ENV.fetch('HACKNEY_REPAIRS_API_BASE_URL') }
  end

  def connection
    @_connection ||= Faraday.new(@base_url) do |faraday|
      faraday.proxy = ENV['QUOTAGUARDSTATIC_URL']
      faraday.response :json
      if defined?(Rails) && !Rails.env.test?
        faraday.response :logger
      end
      faraday.adapter :net_http
    end
  end
end
