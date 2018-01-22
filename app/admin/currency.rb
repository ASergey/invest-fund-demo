ActiveAdmin.register Currency do
  permit_params :id, :name, :symbol, :default

  config.filters       = false
  config.batch_actions = false

  actions :all, except: %i[show]

  index do
    column :name
    column :symbol
    column :default
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :symbol
      f.input :default
    end
    f.actions
  end
end
