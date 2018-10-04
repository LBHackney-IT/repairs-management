FaradayManualCache.configure do |config|
  config.memory_store = ActiveSupport::Cache::RedisStore.new("#{ENV.fetch('REDIS_URL')}/0/cache")
end
