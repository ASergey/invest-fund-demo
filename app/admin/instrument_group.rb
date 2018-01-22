ActiveAdmin.register InstrumentGroup do
  menu parent: I18n.t('admin.instrument.menu_title')

  config.filters       = false
  config.batch_actions = false
  config.sort_order    = 'name_asc'

  permit_params :name, :description

  index do
    id_column
    column :name
    column :created_at
    actions
  end

  form do |f|
    f.inputs I18n.t('admin.instrument.groups.title') do
      f.input :name
      f.input :description, as: :text
    end
    f.actions
  end

  show do |instrument_group|
    attributes_table do
      row :name
      row :description
      row I18n.t('admin.instrument.groups.report_title') do
        link_to(
          instrument_group.name + ' ' + I18n.t('admin.instrument.groups.report_title'),
          admin_instrument_group_reports_path(q: { instrument_instrument_group_id_eq: instrument_group.id })
        )
      end
      row :created_at
    end
  end
end
