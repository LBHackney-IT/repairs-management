module HackneyAPI
  class RepairsClient
    include HttpStatusCodes
    include ApiErrors

    API_CACHE_TIME_IN_SECONDS = 5.minutes.to_i

    def initialize(opts = {})
      @base_url = opts.fetch(:base_url) { ENV.fetch('HACKNEY_REPAIRS_API_BASE_URL') }
    end

    def get_work_order(reference)
      request(
        http_method: :get,
        endpoint: "v1/work_orders/#{reference}"
      )
    end

    def get_repair_request(reference)
      request(
        http_method: :get,
        endpoint: "v1/repairs/#{reference}"
      )
    end

    def get_property(reference)
      request(
        http_method: :get,
        endpoint: "v1/properties/#{reference}"
      )
    end

    def get_work_order_appointments(reference)
      request(
        http_method: :get,
        endpoint: "v1/work_orders/#{reference}/appointments"
      )
    end

    def request(http_method:, endpoint:, cache_request: true, params: {})
      response = begin
        connection(cache_request: cache_request).public_send(http_method, endpoint, **params)
      rescue => e
        raise ApiError, "#{e} #{e.message}, caused by #{e.cause}"
      end

      case response.status
      when HTTP_STATUS_OK
        response.body
      when HTTP_STATUS_NOT_FOUND
        raise RecordNotFoundError, endpoint
      else
        raise ApiError, [endpoint, response.status, response.body].join(', ')
      end
    end

    private

    def connection(cache_request:)
      @_connection ||= Faraday.new(@base_url) do |faraday|
        faraday.use :manual_cache, logger: Rails.logger, expires_in: API_CACHE_TIME_IN_SECONDS if cache_request
        faraday.adapter Faraday.default_adapter
        faraday.proxy = ENV['QUOTAGUARDSTATIC_URL']
        faraday.response :json
        faraday.response :logger unless Rails.env.test?
      end
    end
  end
end
