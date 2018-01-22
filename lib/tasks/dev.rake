namespace :dev do
  desc 'Creates new user account'
  task :create_user, %i[name email password] => [:environment] do
    ARGV.each { |a| task a.to_sym {} }
    user = User.create(name: ARGV[1], email: ARGV[2], password: ARGV[3])

    raise user.errors.full_messages.first if user.errors.present?
  end

  desc 'Generate exchange rates for earlier dates'
  task fill_in_exchange_rates: :environment do
    first_date = ExchangeRate.order(created_at: :desc).first.created_at
    default_currency = Currency.default
    rates = []
    Currency.all.each do |currency|
      next if currency.default?

      rate_hash = ExchangeRate.rate_to_default(currency).order(created_at: :desc).first
      rates << { 
        from_currency: currency,
        to_currency:   default_currency,
        rate:          rate_hash.rate
      }
    end

    daily_rates = []
    (first_date.to_date - 1.month).upto(first_date.to_date - 1.day).each do |rate_date|
      rates.each do |rate|
        daily_rates << rate.merge(created_at: rate_date.strftime("%FT%T"))
      end
    end

    ExchangeRate.create(daily_rates)
  end

  desc 'Build instrument balance reports since date'
  task :instrument_balance_reports_since, %i[date instrument_id] => %i[environment] do
    include ApplicationHelper
    puts "#{Time.current.to_formatted_s(:db)} INFO: Starting building instruments balance reports since date #{task_date_parse}"
    date = task_date_parse
    InstrumentsBalanceDateReportJob.perform_now(date, ARGV[2])
    puts "#{Time.current.to_formatted_s(:db)} INFO: Finished building instruments balance reports since date #{task_date_parse}"
  end
end
