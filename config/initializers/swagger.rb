GrapeSwaggerRails.options.url            = '/api/v1/swagger_doc'
GrapeSwaggerRails.options.app_url        = ENV['ROUTES_HOST']
GrapeSwaggerRails.options.app_name       = 'Invest Admin Panel'
GrapeSwaggerRails.options.api_auth       = 'bearer'
GrapeSwaggerRails.options.api_key_name   = 'Authorization'
GrapeSwaggerRails.options.api_key_type   = 'header'
GrapeSwaggerRails.options.hide_url_input = true

module Grape
  module ContentTypes
    def self.content_types_for(from_settings)
      ActiveSupport::OrderedHash[ :json, 'application/json' ]
    end
  end
end
