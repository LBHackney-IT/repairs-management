API_REQUEST_CACHE = ActiveSupport::Cache::RedisStore.new("#{ENV.fetch('REDIS_URL')}/0/cache")

FaradayManualCache.configure do |config|
  config.memory_store = API_REQUEST_CACHE
end
