module Api
  class ApiController < ApplicationController
    layout :false

    rescue_from StandardError, with: :handle_standard_error
    rescue_from HackneyAPI::RepairsClient::ApiError, with: :handle_api_error
    rescue_from HackneyAPI::RepairsClient::TimeoutError, with: :handle_api_timeout_error

    def handle_api_error(e)
      title =       t('api.errors.repairs_api_error.title')
      description = t('api.errors.repairs_api_error.description')
      description = e.errors["userMessage"] if e.errors["userMessage"].present?
      log_error(e)
      Appsignal.set_error(e)
      ajax_error(title, description)
    end

    def handle_api_timeout_error(e)
      title =       t('api.errors.repairs_api_timeout.title')
      description = t('api.errors.repairs_api_timeout.description')
      log_error(e)
      Appsignal.set_error(e)
      ajax_error(title, description)
    end

    def handle_standard_error(e)
      title =       t('api.errors.standard_error.title')
      description = t('api.errors.standard_error.description')
      description = e.message if e.message != e.class.name 
      log_error(e)
      Appsignal.set_error(e)
      ajax_error(title, description)
    end

    private

    def ajax_error(title, description = nil)
      render(
        status: 500,
        partial: "ajax_error",
        locals: {
          title: title,
          description: description
        }
      )
    end

    # shamelesly copied from action_controller/metal/live.rb
    def log_error(exception)
      logger.fatal do
        message = +"#{exception.class} (#{exception.message}):\n\n"
        message << exception.annotated_source_code.to_s if exception.respond_to?(:annotated_source_code)
        message << "  " << exception.backtrace.join("\n  ")
        "#{message}\n\n"
      end
    end
  end
end
