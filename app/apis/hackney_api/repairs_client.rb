module HackneyAPI
  class RepairsClient
    include HttpStatusCodes

    class HackneyApiError < StandardError; end
    class RecordNotFoundError < HackneyApiError; end
    class ApiError < HackneyApiError; end

    API_CACHE_TIME_IN_SECONDS = 5.minutes.to_i
    API_VERSION = "v1"

    LEVEL_ESTATE = 2
    LEVEL_FACILITIES = 6
    LEVEL_NON_DWELL = 8

    def initialize(opts = {})
      @base_url = opts.fetch(:base_url, ENV.fetch('HACKNEY_REPAIRS_API_BASE_URL'))
    end

    def get_work_orders
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders"
      )
    end

    def get_work_order(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/#{reference}"
      )
    end

    def get_work_orders_by_references(references)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/by_references",
        params: { reference: references }
      )
    end

    def work_order_feed(previous_reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/feed?startId=#{previous_reference}"
      )
    end

    def notes_feed(previous_note_id)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/notes/feed?startId=#{previous_note_id}&noteTarget=uhorder"
      )
    end

    def get_work_order_appointments(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/#{reference}/appointments"
      )
    end

    def get_work_order_appointments_latest(reference)
      response = request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/#{reference}/appointments/latest"
      )
      if response == []
        raise HackneyAPI::RepairsClient::RecordNotFoundError,
              "Can't find appointment for #{reference}"
      else
        response
      end
    end

    def get_work_order_notes(reference)
      request(
        http_method: :get,
        endpoint: notes_endpoint(reference)
      )
    end

    def post_work_order_note(work_order_reference, text)
      value = request(
        http_method: :post,
        endpoint: "#{API_VERSION}/notes",
        headers: {"Content-Type" => "application/json-patch+json"},
        params: {
          objectKey: "uhorder",
          objectReference: work_order_reference,
          text: text
        }.to_json
      )

      url = "prefix-#{@base_url}/#{notes_endpoint(work_order_reference)}"

      API_REQUEST_CACHE.expire(url, 0)

      value
    end

    def get_work_order_reports(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/#{reference}?include=mobilereports"
      )
    end

    def get_work_orders_by_property(references:, date_from:, date_to:)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders",
        params: {
          propertyReference: references,
          since: date_from.strftime("%d-%m-%Y"),
          until: date_to.strftime("%d-%m-%Y")
        }
      )
    rescue HackneyAPI::RepairsClient::RecordNotFoundError
      [] # Handle the case when there are no work orders for a given property. Delete this once API is updated to handle the case
    end

    def get_repair_requests_by_property(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/repairs?propertyReference=#{reference}"
      )
    end

    def get_repair_request(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/repairs/#{reference}"
      )
    end

    def get_property(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties/#{reference}"
      )
    end

    def get_properties_by_references(references)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties/by_references",
        params: { reference: references }
      )
    end

    def get_property_hierarchy(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties/#{reference}/hierarchy"
      )
    end

    def get_property_by_postcode(postcode, min_level=LEVEL_NON_DWELL, max_level=LEVEL_ESTATE)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties",
        params: {
          postcode: postcode,
          min_level: min_level,
          max_level: max_level
        }
      )
    end

    def get_property_block_work_orders_by_trade(reference:, trade:, date_from:, date_to:)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties/#{reference}/block/work_orders?trade=#{trade}&since=#{date_from}&until=#{date_to}"
      )
    rescue HackneyAPI::RepairsClient::RecordNotFoundError
      []
    end

    private

    def notes_endpoint(reference)
      "#{API_VERSION}/work_orders/#{reference}/notes"
    end

    def request(http_method:, endpoint:, cache_request: true, headers: {}, params: {})
      caller = caller_locations.first.label

      response = begin
        Appsignal.instrument("api.#{caller}") do
          connection(cache_request: cache_request, headers: headers).public_send(http_method, endpoint, params)
        end
      rescue => e
        Rails.logger.error(e)
        raise ApiError, [endpoint, params, e.message].join(', ')
      end

      case response.status
      when HTTP_STATUS_OK, HTTP_STATUS_NO_CONTENT
        response.body
      when HTTP_STATUS_NOT_FOUND
        raise RecordNotFoundError, [endpoint, params].join(', ')
      else
        raise ApiError, [endpoint, params, response.status, response.body].join(', ')
      end
    end

    def connection(cache_request:, headers:)
      Faraday.new(@base_url, request: { :params_encoder => Faraday::FlatParamsEncoder }, headers: {"x-api-key"=>"#{ENV['X_API_KEY']}"}.merge(headers)) do |faraday|
        if cache_request && !Rails.env.test?
          faraday.use :manual_cache,
                      logger: Rails.logger,
                      expires_in: API_CACHE_TIME_IN_SECONDS,
                      cache_key: ->(env) { "prefix-#{env.url}" }
        end
        faraday.proxy = ENV['QUOTAGUARDSTATIC_URL']
        faraday.response :json
        faraday.response :logger, Rails.logger unless Rails.env.test?
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
