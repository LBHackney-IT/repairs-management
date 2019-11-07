module HackneyAPI
  class RepairsClient
    include HttpStatusCodes

    class HackneyApiError < StandardError; end
    class RecordNotFoundError < HackneyApiError; end
    class TimeoutError < HackneyApiError; end
    class ApiError < HackneyApiError;
      attr_reader :errors

      def initialize(msg = nil, errors = nil)
        super(msg)
        @errors = errors
      end
    end

    API_CACHE_TIME_IN_SECONDS = 5.minutes.to_i
    API_VERSION = "v1"

    LEVEL_ESTATE = 2
    LEVEL_FACILITIES = 6
    LEVEL_NON_DWELL = 8

    def initialize(opts = {})
      @base_url = opts.fetch(:base_url, ENV.fetch('HACKNEY_REPAIRS_API_BASE_URL'))
      # FIXME: good old normalization. naughty slashes breaking cache.
      @base_url += "/" unless @base_url.ends_with?("/")
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

    def get_work_order_tasks(work_order_reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/#{work_order_reference}/tasks",
      )
    end

    def work_order_feed(previous_reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/work_orders/feed?startId=#{previous_reference}"
      )
    end

    def notes_feed(previous_note_id, limit: 50)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/notes/feed?startId=#{previous_note_id}&noteTarget=uhorder&resultSize=#{limit}"
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
        endpoint: "#{API_VERSION}/work_orders/#{reference}/notes"
      )
    end

    def self.clear_notes_cache_for_work_order(work_order_reference)
      API_REQUEST_CACHE.expire("hackney-api-cache-#{API_VERSION}/work_orders/#{work_order_reference}/notes", 0)
    end

    def post_work_order_note(work_order_reference, text, created_by_email)
      value = request(
        http_method: :post,
        endpoint: "#{API_VERSION}/notes",
        headers: {"Content-Type" => "application/json-patch+json"},
        params: {
          objectKey: "uhorder",
          objectReference: work_order_reference,
          text: text,
          lbhemail: created_by_email
        }.to_json
      )

      self.class.clear_notes_cache_for_work_order(work_order_reference)
      value
    end

    # FIXME: maybe I'm gonna regret this?
    def self.clear_work_order_cache(reference)
      API_REQUEST_CACHE
        .fetch("hackney-api-cache-#{API_VERSION}/work_orders/#{reference}")
        &.dig("body", "propertyReference")
        &.tap {|x| clear_work_orders_cache_for_property(x) }

      API_REQUEST_CACHE.expire("hackney-api-cache-#{API_VERSION}/work_orders/#{reference}", 0)
    end

    def cancel_work_order(reference, created_by_email)
      response = request(
        http_method: :post,
        endpoint: "#{API_VERSION}/work_orders/#{reference}/cancel",
        headers: {"Content-Type" => "application/json-patch+json"},
        params: {
          lbhEmail: created_by_email
        }.to_json
      )

      self.class.clear_work_order_cache(reference)
      response
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

    # Try to clear cache for requests that have this work order.
    # NOTE: there might be requests not covered here.
    def self.clear_work_orders_cache_for_property(property_reference)
      property_reference.present? or raise "property reference required"
      API_REQUEST_CACHE.delete_matched "*work_order*#{property_reference}*"
    end

    # Try to clear cache for requests that have this repair request.
    # NOTE: there might be requests not covered here.
    def self.clear_repairs_cache_for_property(property_reference)
      property_reference.present? or raise "property reference required"
      API_REQUEST_CACHE.delete_matched "*repairs*#{property_reference}*"
    end

    def post_repair_request(name:, phone:, tasks:, priority:, property_ref:, description:, recharge:, created_by_email:)
      response = request(
        http_method: :post,
        endpoint: "#{API_VERSION}/repairs",
        headers: {"Content-Type" => "application/json-patch+json"},
        params: {
          "contact": {
            "name": name,
            "telephoneNumber": phone,
          },
          # FIXME: this should have been named "tasks" on the API side
          "workOrders": tasks.map do |task|
            {
              "sorCode": task.sor_code,
              "estimatedUnits": task.estimated_units
            }
          end,
          "priority": priority,
          "propertyReference": property_ref,
          "problemDescription": description,
          "isRecharge": recharge,
          "lbhEmail": created_by_email
        }.to_json
      )

      self.class.clear_work_orders_cache_for_property(property_ref)
      self.class.clear_repairs_cache_for_property(property_ref)

      response
    end

    def post_work_order_issue(reference, created_by_email:)
      request(
        http_method: :post,
        endpoint: "#{API_VERSION}/work_orders/#{reference}/issue",
        headers: {"Content-Type" => "application/json-patch+json"},
        params: {
          "lbhEmail": created_by_email
        }.to_json
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

    def get_property_by_address(address, min_level=LEVEL_NON_DWELL, max_level=LEVEL_ESTATE, limit:)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties/fladdress",
        params: {
          address: address,
          limit: limit,
          # FIXME: are those two used?
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
    end

    def get_cautionary_contact_by_property_reference(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/cautionary_contact/?reference=#{reference}"
      )
    end

    def get_facilities_by_property_reference(reference)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/properties/#{reference}/facilities"
      )
    end

    def get_keyfax_url(current_page_url)
      request(
        cache_request: false,
        http_method: :get,
        endpoint: "#{API_VERSION}/keyfax/get_startup_url/?returnurl=#{current_page_url}"
      )
    end

    def get_keyfax_result(guid)
      request(
        http_method: :get,
        endpoint: "#{API_VERSION}/keyfax/kf_result/#{guid}"
      )
    end

    private

    def request(http_method:, endpoint:, cache_request: true, headers: {}, params: {})
      caller = caller_locations.first.label

      response = Appsignal.instrument("api.#{caller}") do
        connection(cache_request: cache_request, headers: headers)
          .public_send(http_method, endpoint, params)
      end

      case response.status
      when HTTP_STATUS_OK, HTTP_STATUS_NO_CONTENT
        response.body
      when HTTP_STATUS_NOT_FOUND
        raise RecordNotFoundError, [endpoint, params].join(', ')
      when 504
        raise TimeoutError, [endpoint, params].join(', ')
      else
        API_REQUEST_CACHE.expire("hackney-api-cache-#{endpoint}", 0)
        raise ApiError.new([endpoint, params, response.status, response.body].join(', '), response.body)
      end
    end

    def connection(cache_request:, headers:)
      Faraday.new(@base_url, request: { :params_encoder => Faraday::FlatParamsEncoder }, headers: {"x-api-key"=>"#{ENV['X_API_KEY']}"}.merge(headers)) do |faraday|
        if cache_request
          faraday.use :manual_cache,
                      logger: Rails.logger,
                      expires_in: API_CACHE_TIME_IN_SECONDS,
                      cache_key: ->(env) { "hackney-api-cache-" + env.url.to_s.sub(@base_url, '') }
        end
        faraday.proxy = ENV['QUOTAGUARDSTATIC_URL']
        faraday.response :json
        faraday.response :logger, Rails.logger, bodies: true
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
