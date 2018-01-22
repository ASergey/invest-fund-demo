ActiveAdmin.register FundOperation do
  menu parent: I18n.t('admin.fund.menu_title')

  permit_params :investor_id, :instrument_id, :amount, :currency_id,
                :operation_type, :status, :notes, :payment_resource_type,
                :wallet_id, :id, :user_id, :fund_wallet_from_id, :fund_wallet_to_id,
                :operation_date

  config.batch_actions = false
  config.sort_order    = 'operation_date_desc'

  actions :all, except: %i[destroy]
  before_action :init_gon_vars, only: %i[new create edit update]
  before_create :modify_attributes
  before_update :modify_attributes

  includes :currency
  includes :user

  filter :operation_subject, as: :select, collection: proc { FundOperation.filter_subject_select }
  filter :investor, collection: -> { User.investors_selector }
  filter :instrument
  filter :currency
  filter :created_at
  filter :updated_at

  scope :all, default: true
  scope(I18n.t('enumerize.fund_operation.status.pending')) { |scope| scope.with_status(:pending) }
  scope(I18n.t('enumerize.fund_operation.status.done')) { |scope| scope.with_status(:done) }
  scope(I18n.t('enumerize.fund_operation.status.canceled')) { |scope| scope.with_status(:canceled) }

  index do
    id_column
    column I18n.t('admin.fund_operations.operation_author') do |operation|
      operation.user
    end
    column :investor
    column :instrument
    column :amount { |o| number_format(o.amount) }
    column :currency do |operation|
      operation.currency.symbol
    end
    column :operation_type do |operation|
      status_tag operation.operation_type.text, class: operation.operation_type.tr('_', '-')
    end
    column :status do |operation|
      status_tag operation.status.text, class: operation.status
    end
    column :operation_date
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    render partial: 'admin/operation/form', locals: { f: f }
  end

  show do |operation|
    attributes_table do
      row I18n.t('admin.fund_operations.show_title') do
        operation.user
      end
      row :instrument if operation.instrument.present?

      if resource.investor.present?
        row :investor
        row :wallet do |operation_row|
          operation_row.wallet.name if operation_row.wallet.present?
        end
        row :kyc_document if resource.kyc_document.present?
      end

      row :amount { |op| number_format(op.amount) }
      row :currency
      row :operation_type do
        status_tag operation.operation_type.text, class: operation.operation_type.tr('_', '-')
      end
      row :fund_wallet_from if operation.fund_wallet_from.present?
      row :fund_wallet_to if operation.fund_wallet_to.present?
      row :status do
        status_tag operation.status.text, class: operation.status
      end
      row :operation_date
      row :created_at
      row :updated_at
      row :notes
    end
  end

  sidebar :investor_totals, only: :show, if: proc { resource.investor.present? } do
    if resource.investor.present?
      operations_user = resource.investor
      attributes_table_for operations_user do
        render partial: 'admin/user/totals_sidebar', locals: { operations_user: operations_user }
      end
      link_to(
        I18n.t('admin.user.named_operations', investor_name: operations_user.name),
        admin_user_fund_operations_path(operations_user)
      )
    end
  end

  controller do
    belongs_to :user, :instrument, polymorphic: true, optional: true

    def scoped_collection
      return FundOperation.by_investor(params[:user_id]) if params[:user_id].present?
      super
    end

    def build_new_resource
      resource = super
      resource.assign_attributes(user: current_user)
      resource
    end

    def modify_attributes(operation)
      operation.assign_attributes(operation_params)
      authorize!(:approve_operation, operation) if operation.made_done? || operation.made_undone?
    end

    def create
      super do
        if resource.valid?
          redirect_to collection_url, notice: I18n.t('admin.fund_operations.operation_created')
          return
        end
      end
    end

    def edit
      if resource.investor.present?
        resource.payment_resource_type = resource.kyc_document.present? ?
          FundOperation::RESOURCE_TYPE_BANK_ACCOUNT : FundOperation::RESOURCE_TYPE_WALLET
      end
      super
    end

    def update
      if resource.investor.present?
        resource.payment_resource_type = resource.kyc_document.present? ?
          FundOperation::RESOURCE_TYPE_BANK_ACCOUNT : FundOperation::RESOURCE_TYPE_WALLET
      end
      super do
        if resource.valid?
          redirect_to collection_url, notice: I18n.t('admin.fund_operations.operation_updated')
          return
        end
      end
    end

    def init_gon_vars
      gon.push(investor_wallets_url: list_investor_wallets_admin_users_path)
    end

    def operation_permitted_params
      %i[user investor_id instrument_id amount currency_id operation_type status notes payment_resource_type
         wallet_id id fund_wallet_from_id fund_wallet_to_id operation_date]
    end

    def registered_operation_params(operation)
      operation.attributes.extract!(*operation_permitted_params.map(&:to_s))
    end

    def operation_params
      result = params.require(:fund_operation).permit(operation_permitted_params)
      result = registered_operation_params(resource).merge(result).symbolize_keys

      investor_operation_params(result) if result[:investor_id].present?
      result
    end

    def investor_operation_params(investor_params)
      if investor_params[:payment_resource_type].blank?
        investor_params[:payment_resource_type] = resource.payment_resource_type
      end

      if investor_params[:payment_resource_type] == FundOperation::RESOURCE_TYPE_BANK_ACCOUNT
        investor_params[:kyc_document] = KycDocument.find_by(user_id: investor_params[:investor_id])
        investor_params[:wallet_id]    = nil
      else
        wallet = Wallet.find(investor_params[:wallet_id]) if investor_params[:wallet_id].present?
        if wallet.present?
          investor_params[:currency_id]  = wallet.currency.id
          investor_params[:wallet_id]    = wallet.id
          investor_params[:kyc_document] = nil
        end
      end
      investor_params
    end
  end
end
