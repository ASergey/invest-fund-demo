ActiveAdmin.register InstrumentBalance do
  config.batch_actions = false

  belongs_to      :instrument
  navigation_menu :instrument
  permit_params   :id, :instrument_id, :amount, :currency_id, 
                  instrument_hash_balances_attributes: %i[id hash_amount hash_rate hash_code _destroy]
  actions         :all, except: :show
  filter          :currency

  index do
    id_column
    column :instrument
    column I18n.t('admin.instrument.balance.amount'), :amount
    column I18n.t('admin.instrument.balance.total_balance') do |balance|
      balance.total_balance
    end
    column :currency
    column I18n.t('admin.instrument.balance.hash_balance') do |balance|
      if balance.instrument_hash_balances.count > 0
        table_for balance.instrument_hash_balances do
          column :hash_code
          column :hash_amount
          column :hash_rate
        end
      end
    end if %w[hashnest bixin].include?(instrument.instrument_type)
    column :updated_at
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs I18n.t('admin.instrument.balance.form_title', instrument_name: f.object.instrument.name) do
      f.input :amount, as: :number, label: I18n.t('admin.instrument.balance.account_balance')
      f.input :currency, as: :select2, collection: Currency.select_options

      if f.object.instrument.instrument_type.hashnest? || f.object.instrument.instrument_type.bixin?
        f.inputs I18n.t('admin.instrument.balance.hash_balance'), id: 'hash-balance-inputs' do
          f.has_many :instrument_hash_balances, 
                     heading: nil,
                     allow_destroy: true,
                     new_record: true do |hb|
            hb.input :hash_code
            hb.input :hash_amount, as: :number
            hb.input :hash_rate, as: :number
          end
        end
      end
    end
    f.actions
  end
end
