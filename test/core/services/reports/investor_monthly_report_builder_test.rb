require 'test_helper'

class InvestorMonthlyReportBuilderTest < ActiveSupport::TestCase
  def setup
    Time.zone = 'UTC'
    Timecop.freeze(Time.zone.local(2017, 10, 1, 0, 13, 0))
    Setting.stubs(:management_fee).returns(0.002)

    @usd      = create(:currency_usd, default: true)
    @investor = create(:user_investor)

    Services::Reports::InvestorMonthlyReportBuilder.any_instance.stubs(:calc_management_fee).returns(200.0)
    @builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)
  end

  test 'user not found' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Services::Reports::InvestorMonthlyReportBuilder.new(0)
    end
  end

  test 'user to find is not investor' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Services::Reports::InvestorReportBuilder.new(create(:user).id)
    end
  end

  test 'insufficient data error' do
    assert_nothing_raised do
      Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)
    end

    Services::Reports::InvestorMonthlyReportBuilder.any_instance.unstub(:calc_management_fee)
    error = assert_raises(RuntimeError) do
      Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)
    end
    assert_match(/Not enough data to build monthly report for investor/i, error.message)
  end

  test 'initialize without monthly profit' do
    assert_equal 200.0, @builder.fee_amount
    assert_equal 0.0, @builder.amount
  end

  test 'initialize with monthly profit' do
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    assert_equal 200.0, builder.fee_amount
    assert_equal 500.0, builder.amount
  end

  test 'calculate management fee' do
    Services::Reports::InvestorMonthlyReportBuilder.any_instance.unstub(:calc_management_fee)
    assert_nil @builder.send(:calc_management_fee)

    report = create(
      :investor_report,
      user:           @investor,
      currency:       @usd,
      amount:         1_000.0,
      capitalization: 1_500.0,
      report_date:    1.day.ago.to_date
    )
    assert_equal report.capitalization * Setting.management_fee, @builder.send(:calc_management_fee)
  end

  test 'payout amount (dividend with fees)' do
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    assert_predicate builder, :divident_amount_positive?
    assert_equal 500.0 - 200.0, builder.send(:payout_amount)
  end

  test 'payout amount: negative profit' do
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(-100.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    assert_not_predicate builder, :divident_amount_positive?
    assert_equal 0.0, builder.send(:payout_amount)
  end

  test 'payout amount: negative result' do
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(100.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    assert_not_predicate builder, :divident_amount_positive?
    assert_equal 0.0, builder.send(:payout_amount)
  end

  test 'report data' do
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    expected_report_data = {
      user:            @investor,
      dividend_amount: 500.0,
      management_fee:  200.0,
      payout_amount:   500.0 - 200.0,
      currency:        @usd,
      report_date:     1.day.ago.to_date
    }
    assert_equal expected_report_data, builder.send(:report_data)
  end

  test 'builder call raises validation exception' do
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    assert_raises(ActiveRecord::RecordInvalid) do
      builder.call
    end
  end

  test 'builder main workflow (call)' do
    create(:user_admin)
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    builder.stubs(:divident_amount_positive?).returns(true)
    builder.expects(:reinvest_dividend).with(300.0)
    builder.expects(:payout_management_fee).with(200.0)

    assert builder.call
  end

  test 'builder call without reinvest' do
    create(:user_admin)
    investor = create(:user_investor, reinvest: false)
    InvestorReport.expects(:monthly_profit).with(investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(investor.id)

    builder.stubs(:divident_amount_positive?).returns(true)
    builder.expects(:payout_management_fee).with(200.0)
    builder.expects(:payout_dividend).with(300.0)

    assert builder.call
  end

  test 'create reinvestment operations' do
    create(:user_admin)
    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)

    assert_difference('FundOperation.count', 3) { assert builder.call }
    fee_operation = FundOperation.by_investor(@investor.id).by_date(Date.current)
                                 .where(
                                   operation_type: FundOperation::TYPE_MANAGEMENT_FEE,
                                   status: FundOperation::STATUS_PENDING
                                 ).first
    payout_operation = FundOperation.by_investor(@investor.id).by_date(Date.current)
                                    .where(
                                      operation_type: FundOperation::TYPE_PAYOUT,
                                      status: FundOperation::STATUS_DONE
                                    ).first
    investment_operation = FundOperation.by_investor(@investor.id).by_date(Date.current)
                                        .where(
                                          operation_type: FundOperation::TYPE_PAYOUT,
                                          status: FundOperation::STATUS_DONE
                                        ).first

    assert_equal 200.0, fee_operation.amount
    assert_equal 300.0, payout_operation.amount
    assert_equal 300.0, investment_operation.amount
  end

  test 'create operations without reinvestment' do
    create(:user_admin)
    investor = create(:user_investor, reinvest: false)
    InvestorReport.expects(:monthly_profit).with(investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(investor.id)

    assert_difference('FundOperation.count', 2) { assert builder.call }
    fee_operation = FundOperation.by_investor(investor.id).by_date(Date.current)
                                 .where(
                                   operation_type: FundOperation::TYPE_MANAGEMENT_FEE,
                                   status: FundOperation::STATUS_PENDING
                                 ).first
    payout_operation = FundOperation.by_investor(investor.id).by_date(Date.current)
                                    .where(
                                      operation_type: FundOperation::TYPE_PAYOUT,
                                      status: FundOperation::STATUS_PENDING
                                    ).first

    assert_equal 200.0, fee_operation.amount
    assert_equal 300.0, payout_operation.amount
  end

  test 'update existing monthly report' do
    create(:user_admin)
    create(:investor_monthly_report, user: @investor, currency: @usd)

    InvestorReport.expects(:monthly_profit).with(@investor.id, 1.day.ago.to_date).returns(500.0)
    builder = Services::Reports::InvestorMonthlyReportBuilder.new(@investor.id)
    assert_difference('FundOperation.count', 3) do
      assert_no_difference('InvestorMonthlyReport.count') do
        assert builder.call
      end
    end
  end

  def teardown
    Timecop.return
  end
end
