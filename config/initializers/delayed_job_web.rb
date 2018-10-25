DelayedJobWeb.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(ENV.fetch('DELAYED_JOB_WEB_USER'), username) &
    ActiveSupport::SecurityUtils.secure_compare(ENV.fetch('DELAYED_JOB_WEB_PASSWORD'), password)
end
