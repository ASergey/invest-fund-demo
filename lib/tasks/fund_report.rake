namespace :fund_report do
  desc 'Get currency exchange rates'
  task exchange_rates: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting exchange rates update"
    ExchangeRatesJob.perform_later
    puts "#{Time.current.to_formatted_s(:db)} INFO: Exchange rates update finished"
  end

  desc 'Generate daily fund and instrument balances report (last day)'
  task last_day_balance_report: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting fund balances daily report"
    FundBalanceReportJob.perform_later
    Instrument.all.each do |instrument|
      InstrumentsBalanceReportJob.perform_later(instrument.id)
    end
    puts "#{Time.current.to_formatted_s(:db)} INFO: Fund balances daily report finished"
  end

  desc 'Generate daily fund totals report (last_day)'
  task :fund_report, %i[date] => %i[environment] do
    include ApplicationHelper
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting fund totals daily report"
    FundReportJob.perform_later(task_date_parse)
    puts "#{Time.current.to_formatted_s(:db)} INFO: Fund totals daily report finished"
  end

  desc 'Generate daily investor totals report'
  task :investor_report, %i[date] => %i[environment] do
    include ApplicationHelper
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting investor totals daily report"
    InvestorReportJob.perform_later(task_date_parse)
    puts "#{Time.current.to_formatted_s(:db)} INFO: Investor totals daily report finished"
  end

  desc 'Generate monthly investor dividends and fees operations'
  task investor_dividends: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting investors dividends monthly report"
    User.investor.each do |investor|
      begin
        InvestorDividendsJob.perform_later(investor.id)
      rescue StandardError => e
        puts "#{Time.current.to_formatted_s(:db)} WARNING: #{e.message}"
      end
    end
    puts "#{Time.current.to_formatted_s(:db)} INFO: Investors dividends monthly report finished"
  end

  desc 'Rebuild reports since date (where report data exists)'
  task :build_balance_reports_since, %i[date] => %i[environment] do
    include ApplicationHelper
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting building fund balance and instruments balance reports since date #{task_date_parse}"
    date = task_date_parse
    FundBalanceDateReportJob.perform_later(date)
    Instrument.all.each do |instrument|
      InstrumentsBalanceDateReportJob.perform_later(date, instrument.id)
    end
    puts "#{Time.current.to_formatted_s(:db)} INFO: Finished building fund balance and instruments balance reports since date #{task_date_parse}"
  end
end
