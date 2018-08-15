module ApiErrors
  class HackneyApiError < StandardError; end

  class RecordNotFoundError < HackneyApiError; end
  class ApiError < HackneyApiError; end
end
