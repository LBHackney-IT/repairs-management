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
      # FIXME: log errors
      Appsignal.set_error(e)
      ajax_error(title, description)
    end

    def handle_api_timeout_error(e)
      title =       t('api.errors.repairs_api_timeout.title')
      description = t('api.errors.repairs_api_timeout.description')
      # FIXME: log errors
      Appsignal.set_error(e)
      ajax_error(title, description)
    end

    def handle_standard_error(e)
      title =       t('api.errors.standard_error.title')
      description = t('api.errors.standard_error.description')
      description = e.message if e.message != e.class.name 
      # FIXME: log errors
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
  end
end
