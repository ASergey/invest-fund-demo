ActiveAdmin.register User do
  config.batch_actions  = false

  permit_params :id, :email, :name, :password, :password_confirmation, :phone, :is_gp, :is_lp, :reinvest,
                role_ids: [], kyc_document_attributes: %i[id first_name last_name address _destroy],
                investor_wallets_attributes: %i[id name address currency_id _destroy]

  scope :all, default: true, if: proc { can?(:manage, User) }
  scope :investor, if: proc { can?(:manage, User) }

  filter :email
  filter :name

  collection_action :list_investor_wallets, method: :get

  index do
    id_column
    column :email
    column :name
    column :phone
    column :is_gp
    column :is_lp
    column :reinvest
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :updated_at
    actions defaults: true do |user|
      actions = []
      actions << link_to(I18n.t('admin.user.operations'), admin_user_fund_operations_path(user), class: 'member_link') if user.investor?
      actions << link_to(I18n.t('admin.user.dailay_report'), admin_user_investor_reports_path(user), class: 'member_link') if user.investor?
      actions << link_to(I18n.t('admin.user.monthly_report'), admin_user_investor_monthly_reports_path(user), class: 'member_link') if user.investor?
      actions.join.html_safe
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :email
      f.input :name
      if f.object.new_record? || f.object.id == current_user.id
        f.input :password
        f.input :password_confirmation
      end
      f.input :roles, label: I18n.t('admin.user.role'), as: :select, input_html: { multiple: false }, collection: Role::select_collection if can?(:edit_roles, current_user)
      if f.object.new_record? || f.object.investor?
        f.input :phone
        f.input :reinvest, label: I18n.t('admin.user.reinvest_label')
      end
      f.input :is_gp, label: I18n.t('admin.user.general_partner')
      f.input :is_lp, label: I18n.t('admin.user.limited_partner')
    end

    if f.object.new_record? || f.object.investor?
      f.inputs I18n.t('admin.user.wallets'), id: 'wallets-input' do
        f.has_many :investor_wallets,
                   heading: nil,
                   allow_destroy: true,
                   new_record: true do |w|
          w.input :address
          w.input :name
          w.input :currency, as: :select, collection: Currency.all
        end
      end
    end

    if f.object.new_record? || f.object.investor?
      f.inputs I18n.t('admin.user.kyc'), id: 'kyc-inputs' do
        f.has_many :kyc_document, 
                   heading: nil,
                   allow_destroy: true,
                   new_record: f.object.kyc_document.blank? do |k|
          k.input :first_name
          k.input :last_name
          k.input :address
        end
      end
    end

    f.actions
  end

  show do |u|
    attributes_table do
      row :name
      row :email
      row :roles do |user|
        RoleName::description(user.roles.first.name.to_sym)
      end
      row :phone
      row :is_gp
      row :is_lp
      row :reinvest
      row :current_sign_in_ip
      row :sign_in_count
      row :created_at
    end

    if resource.investor_wallets.present?
      panel I18n.t('admin.user.wallets') do
        table_for resource.investor_wallets do
          column :name
          column :address
          column :currency
          column :created_at
          column :updated_at
        end
      end
    end

    if resource.kyc_document.present?
      panel I18n.t('admin.user.kyc') do
        attributes_table_for resource.kyc_document do
          row :first_name
          row :last_name
          row :address
        end
      end
    end
  end

  sidebar :investor_totals, only: [:edit, :update, :show], if: proc{ resource.investor? } do
    render partial: 'admin/user/totals_sidebar', locals: { operations_user: resource }
    ul do
      li { link_to(I18n.t('admin.user.named_operations', investor_name: resource.name), admin_user_fund_operations_path(resource)) }
      li { link_to(I18n.t('admin.user.dailay_report'), admin_user_investor_reports_path(resource)) }
      li { link_to(I18n.t('admin.user.monthly_report'), admin_user_investor_monthly_reports_path(resource)) }
    end
  end

  controller do
    def scoped_collection
      return User.all if can?(:manage, User)
      return User.investor
    end

    def find_resource
      user = User.find(params[:id])
      authorize!(:manage_investor, user)
      user
    end

    def build_new_resource
      super.tap do |resource|
        resource.add_role(RoleName::INVESTOR) if params[:user].present? && params[:user][:role_ids].blank?
      end
    end

    def list_investor_wallets
      user = User.find(params[:id])
      return ajax_error(I18n.t('admin.user.must_be_investor')) unless user.present? && user.investor?

      result = []
      user.investor_wallets.each do |wallet|
        result << { id: wallet.id, text: wallet.name + ' - ' + wallet.currency.symbol }
      end
      ajax_ok({ wallets:  result})
    end
  end
end
