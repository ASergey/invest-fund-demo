ActiveAdmin.register_page 'Setting' do
  title = I18n.t('admin.setting.title')
  menu label: title, priority: 99
  active_admin_settings_page(title: title)
end
