module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      require './lib/jwt_auth'

      def self.logger
        @logger ||= (ENV['LOG_TO_FILE'].to_i == 0 ? Logger.new(STDOUT) : Logger.new("#{Rails.root}/log/api.log"))
      end

      def self.api_error(api, message, api_code, status, details = nil)
        request = Rack::Request.new(api.env)
        description = {
          path:   request.path,
          method: request.request_method,
          status: status,
          ip:     request.ip,
          params: ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters).filter(request.params)
        }
        logger.error message + ' REQUEST -- : ' + description.to_json
        api.error!({ error: message, code: api_code, details: details }, status)
      end

      included do
        prefix 'api'
        version 'v1', using: :path
        default_format :json
        format :json

        before do
          authenticate
          if 1 == ENV['API_LOG_REQUEST'].to_i
            API::V1::Defaults.logger.info "REQUEST -- : #{ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters).filter(request.params).to_json}"
          end
        end

        helpers do
          def authenticate
            API::V1::Defaults.api_error(self, I18n.t('api.auth_bearer_required'), ApiResponseCode::UNAUTHORIZED_ERROR, 401) unless auth_present?
            auth = ::JwtAuth::decode(token)
            ApiClient.find_by(client_key: auth.first['client_key']) if auth.first['client_key'].present?
          end

          def token
            request.env['HTTP_AUTHORIZATION'].scan(/Bearer (.*)$/).flatten.last
          end

          def auth_present?
            !!request.env.fetch('HTTP_AUTHORIZATION', '').scan(/Bearer/).flatten.first unless request.env.fetch('HTTP_AUTHORIZATION', '').blank?
          end

          def api_params
            @api_params ||= ActionController::Parameters.new(params)
          end

          def api_request
            @api_request ||= Rack::Request.new(env)
          end

          def send_success
            { code: 'ok' }
          end
        end

        rescue_from JWT::DecodeError do
          API::V1::Defaults.api_error(self, I18n.t('api.auth_error'), ApiResponseCode::UNAUTHORIZED_ERROR, 401)
        end

        # global handler for simple not found case
        rescue_from ActiveRecord::RecordNotFound do |e|
          API::V1::Defaults.api_error(self, e.message, ApiResponseCode::NOT_FOUND_ERROR, 404)
        end

        rescue_from ActiveRecord::RecordInvalid, ApiErrors::ValidationError do |e|
          message = e.message
          message = e.full_messages.first if e.instance_of?(Grape::Exceptions::ValidationErrors)
          details = nil
          details = e.details if e.instance_of?(ApiErrors::ValidationError)
          API::V1::Defaults.api_error(self, message, ApiResponseCode::VALIDATION_ERROR, 422, details)
        end

        # global exception handler, used for error notifications
        rescue_from :all do |e|
          API::V1::Defaults.logger.error("Internal server error: #{e.message} Backtrace: #{e.backtrace}")
          API::V1::Defaults.api_error(self, 'Internal server error', ApiResponseCode::SERVER_ERROR, 500)
        end
      end
    end
  end
end
