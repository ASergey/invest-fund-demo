ActiveAdmin.register Instrument do
  menu parent: I18n.t('admin.instrument.menu_title')

  config.batch_actions = false
  config.sort_order    = 'name_asc'

  permit_params :name, :notes, :instrument_type, :instrument_group_id
  filter        :name
  filter        :instrument_group

  index do
    id_column
    column :name
    column :instrument_group
    column :created_at
    column :updated_at
    actions defaults: true do |instrument|
      actions = []
      actions << link_to(I18n.t('admin.instrument.operations'), admin_instrument_fund_operations_path(instrument), class: 'member_link')
      actions << link_to(I18n.t('admin.instrument.balance.title'), admin_instrument_instrument_balances_path(instrument), class: 'member_link')
      actions << link_to(I18n.t('admin.instrument.report.title'), admin_instrument_instrument_reports_path(instrument), class: 'member_link')
      actions.join.html_safe
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :instrument_type, as: :select, include_blank: false, collection: Instrument.instrument_type.options
      f.input :instrument_group, as: :select
      f.input :notes
    end
    f.actions
  end

  show do |instrument|
    attributes_table do
      row :name
      row :instrument_group
      row I18n.t('admin.instrument.balance.links') do
        ul do
          li link_to(I18n.t('admin.instrument.operations'), admin_instrument_fund_operations_path(instrument))
          li link_to(I18n.t('admin.instrument.balance.title'), admin_instrument_instrument_balances_path(instrument))
          li link_to(I18n.t('admin.instrument.report.title'), admin_instrument_instrument_reports_path(instrument))
        end
      end
      row :notes
    end
  end
end
