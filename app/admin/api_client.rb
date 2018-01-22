ActiveAdmin.register ApiClient do
  permit_params :id, :name, :client_key, :notes
  config.filters = false

  index do
    id_column
    column :name
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :client_key
      f.input :notes
    end
    f.actions
  end

  controller do
    def build_new_resource
      resource = super
      resource.assign_attributes(client_key: SecureRandom.hex(64)) unless params[:api_client].present? && params[:api_client][:client_key].present?
      resource
    end
  end
end
