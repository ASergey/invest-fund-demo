module ApplicationHelper
  include ActionView::Helpers::NumberHelper

  def number_format(number)
    number_with_precision(number, precision: 9, strip_insignificant_zeros: true)
  end

  def last_month_date
    1.month.ago.end_of_month.to_date
  end

  def task_date_parse
    ARGV.each { |a| task a.to_sym {} }
    begin
      return Date.parse(ARGV[1]).to_s if ARGV[1].present?
    rescue ArgumentError
      Rollbar.warning(I18n.t("report.invalid_parse_date_arg", argument: ARGV[1]), argument: ARGV[1])
      Rails.logger.warn(I18n.t("report.invalid_parse_date_arg", argument: ARGV[1]))
    end
    1.day.ago.to_date.to_s
  end
end
