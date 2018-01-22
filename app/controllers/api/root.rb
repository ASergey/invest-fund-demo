class API::Root < Grape::API
  mount API::V1::Root
end
