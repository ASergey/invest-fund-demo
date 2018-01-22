ActiveAdmin.register_page "Jobs List" do

  page_action :exchange_rates, method: :get do
    ExchangeRatesJob.perform_later
    redirect_to admin_jobs_list_path, notice: "Exchange rates job was pushed to the queue"
  end

  page_action :last_day_balance_report, method: :get do
    FundBalanceReportJob.perform_later
    Instrument.all.each do |instrument|
      InstrumentsBalanceReportJob.perform_later(instrument.id)
    end
    redirect_to admin_jobs_list_path, notice: "Last day balance report generation was pushed to the queue"
  end

  action_item :add do
    link_to "Run exchange rates job", admin_jobs_list_exchange_rates_path, method: :get
  end

  action_item :add do
    link_to "Run last day balance report", admin_jobs_list_last_day_balance_report_path, method: :get
  end
end
