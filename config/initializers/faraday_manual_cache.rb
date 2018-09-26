FaradayManualCache.configure do |config|
  config.memory_store = ActiveSupport::Cache::RedisStore.new
end
