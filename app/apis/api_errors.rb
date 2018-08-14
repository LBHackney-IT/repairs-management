module ApiErrors
  RecordNotFoundError = Class.new(StandardError)
  ApiError = Class.new(StandardError)
end
