ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t('active_admin.dashboard') } do
    if can?(:read_fund_stats, current_user)
      columns do
        column do
          panel I18n.t('admin.fund_state_title') do
            table_for FundBalance.all do
              column(I18n.t('admin.fund_balance.currency')) { |balance| balance.currency }
              column(I18n.t('admin.fund_balance.amount')) { |balance| number_format(balance.amount) }
              column(I18n.t('admin.fund_balance.updated')) { |balance| balance.updated_at }
            end
          end
        end
        column do
        end
      end # columns
    end
  end # content
end
