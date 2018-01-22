require 'test_helper'

class ApplicationHelperTest < ActionController::TestCase
  include ApplicationHelper

  test 'number format' do
    assert_equal '123', number_format(123.0)
    assert_equal '123.123456789', number_format(123.123456789)
    assert_equal '0.123456789', number_format(0.1234567891)
    assert_equal '0.123456789', number_format(0.12345678910000)
  end

  test 'last month date' do
    Time.zone = 'UTC'
    travel_to Time.zone.local(2017, 10, 1, 0, 13, 0)
    assert_equal '2017-09-30', last_month_date.to_s

    travel_to Time.zone.local(2017, 9, 30, 0, 13, 0)
    assert_equal '2017-08-31', last_month_date.to_s

    travel_back
  end
end
