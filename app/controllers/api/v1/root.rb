require 'grape-swagger'

class API::V1::Root < Grape::API
  mount API::V1::Currencies
  mount API::V1::Instruments
  mount API::V1::InstrumentBalances
  add_swagger_documentation(
    info: {
      title: I18n.t('api.docs.title'),
      description: I18n.t('api.docs.desc')
    },
    api_version:             'v1',
    version:                 'v1',
    hide_documentation_path: true,
    mount_path:              '/api/v1/swagger_doc',
    hide_format:             true,
    format:                  :json
  )
end
