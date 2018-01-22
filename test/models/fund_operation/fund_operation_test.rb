require 'test_helper'

class FundOperationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'calculate balances never call' do
    FundOperation.any_instance.expects(:calc_balances).never
    create(:fund_operation, :done, skip_calc_balances: true)
  end

  test 'balances are not calculated' do
    Services::CalcBalances::Fund.any_instance.expects(:call).with(false).times(6)
    Services::CalcBalances::Fund.any_instance.expects(:call).with(nil).never
    Services::CalcBalances::Instrument.any_instance.expects(:call).never
    Services::CalcBalances::CalcFundReport.any_instance.expects(:call).never
    Services::CalcBalances::CalcInstrumentReport.any_instance.expects(:call).never

    pending   = create(:fund_operation)
    canceled  = create(:fund_operation, :canceled)
    done_skip = create(:fund_operation, :done, skip_calc_balances: true)

    pending.update(status: FundOperation::STATUS_CANCELED)
    canceled.update(status: FundOperation::STATUS_PENDING)
    done_skip.update(status: FundOperation::STATUS_DONE)

    assert_enqueued_jobs 0
  end

  test 'balances calculated with investor' do
    Services::CalcBalances::Fund.any_instance.expects(:call).with(nil).times(3)
    Services::CalcBalances::Fund.any_instance.expects(:call).with(false).times(6)
    Services::CalcBalances::Instrument.any_instance.expects(:call).never
    Services::CalcBalances::CalcFundReport.any_instance.expects(:call).never
    Services::CalcBalances::CalcInstrumentReport.any_instance.expects(:call).never

    pending  = create(:fund_operation)
    canceled = create(:fund_operation, :canceled)
    done     = create(:fund_operation, :done)

    pending.update(status: FundOperation::STATUS_DONE)
    canceled.update(status: FundOperation::STATUS_DONE)
    done.update(status: FundOperation::STATUS_DONE)

    assert_enqueued_jobs 0
  end

  test 'balances calculated with instrument' do
    Services::CalcBalances::Fund.any_instance.expects(:call).never
    Services::CalcBalances::Instrument.any_instance.expects(:call).with(nil).times(3)
    Services::CalcBalances::Instrument.any_instance.expects(:call).with(false).times(6)
    Services::CalcBalances::CalcFundReport.any_instance.expects(:call).never
    Services::CalcBalances::CalcInstrumentReport.any_instance.expects(:call).never

    pending  = create(:fund_operation, :instrument_operation)
    canceled = create(:fund_operation, :instrument_operation, :canceled)
    done     = create(:fund_operation, :instrument_operation, :done)

    pending.update(status: FundOperation::STATUS_DONE)
    canceled.update(status: FundOperation::STATUS_DONE)
    done.update(status: FundOperation::STATUS_DONE)

    assert_enqueued_jobs 0
  end

  test 'reports calculated with investor' do
    Services::CalcBalances::Fund.any_instance.expects(:call).with(nil).times(3)
    Services::CalcBalances::Fund.any_instance.expects(:call).with(false).times(6)
    Services::CalcBalances::Instrument.any_instance.expects(:call).never
    Services::CalcBalances::CalcFundReport.any_instance.expects(:call).times(3)
    Services::CalcBalances::CalcInstrumentReport.any_instance.expects(:call).never

    operation_date = 5.days.ago.to_date
    pending        = create(:fund_operation)
    canceled       = create(:fund_operation, :canceled)
    done           = create(:fund_operation, :done, operation_date: 7.days.ago.to_date)

    pending.update(status: FundOperation::STATUS_DONE, operation_date: operation_date)
    canceled.update(status: FundOperation::STATUS_DONE, operation_date: operation_date)
    done.update(status: FundOperation::STATUS_DONE, operation_date: operation_date)

    assert_enqueued_jobs 3
  end

  test 'reports calculated with instrument' do
    Services::CalcBalances::Fund.any_instance.expects(:call).never
    Services::CalcBalances::Instrument.any_instance.expects(:call).with(nil).times(3)
    Services::CalcBalances::Instrument.any_instance.expects(:call).with(false).times(6)
    Services::CalcBalances::CalcFundReport.any_instance.expects(:call).times(3)
    Services::CalcBalances::CalcInstrumentReport.any_instance.expects(:call).times(3)

    operation_date = 5.days.ago.to_date
    pending  = create(:fund_operation, :instrument_operation)
    canceled = create(:fund_operation, :instrument_operation, :canceled)
    done     = create(:fund_operation, :instrument_operation, :done, operation_date: 7.days.ago.to_date)

    pending.update(status: FundOperation::STATUS_DONE, operation_date: operation_date)
    canceled.update(status: FundOperation::STATUS_DONE, operation_date: operation_date)
    done.update(status: FundOperation::STATUS_DONE, operation_date: operation_date)

    assert_enqueued_jobs 3
  end

  test 'new operation made done' do
    pending_operation  = build(:fund_operation)
    canceled_operation = build(:fund_operation, :canceled)
    done_operation     = build(:fund_operation, status: :done)

    assert_equal false, pending_operation.made_done?
    assert_equal false, canceled_operation.made_done?
    assert done_operation.made_done?
  end

  test 'operation made done' do
    pending_operation  = create(:fund_operation)
    canceled_operation = create(:fund_operation, :canceled)
    done_operation     = create(:fund_operation, :done)

    pending_operation.status  = FundOperation::STATUS_CANCELED
    canceled_operation.status = FundOperation::STATUS_PENDING

    assert_equal false, pending_operation.made_done?
    assert_equal false, canceled_operation.made_done?

    pending_operation.status  = FundOperation::STATUS_DONE
    canceled_operation.status = FundOperation::STATUS_DONE
    done_operation.status     = FundOperation::STATUS_DONE

    assert pending_operation.made_done?
    assert canceled_operation.made_done?
    assert_equal false, done_operation.made_done?
  end

  test 'new operation made undone' do
    pending_operation  = build(:fund_operation)
    canceled_operation = build(:fund_operation, :canceled)
    done_operation     = build(:fund_operation, :done)

    assert_equal false, pending_operation.made_undone?
    assert_equal false, canceled_operation.made_undone?
    assert_equal false, done_operation.made_undone?
  end

  test 'operation made undone' do
    pending_operation  = create(:fund_operation)
    canceled_operation = create(:fund_operation, :canceled)
    done_operation     = create(:fund_operation, :done)
    done_operation2    = create(:fund_operation, :done)

    assert_equal false, pending_operation.made_undone?
    assert_equal false, canceled_operation.made_undone?
    assert_equal false, done_operation.made_undone?
    assert_equal false, done_operation2.made_undone?

    pending_operation.status  = FundOperation::STATUS_CANCELED
    canceled_operation.status = FundOperation::STATUS_PENDING

    assert_equal false, pending_operation.made_undone?
    assert_equal false, canceled_operation.made_undone?

    pending_operation.status  = FundOperation::STATUS_DONE
    canceled_operation.status = FundOperation::STATUS_DONE
    done_operation.status     = FundOperation::STATUS_PENDING
    done_operation2.status    = FundOperation::STATUS_CANCELED

    assert_equal false, pending_operation.made_undone?
    assert_equal false, canceled_operation.made_undone?
    assert done_operation.made_undone?
    assert done_operation2.made_undone?
  end

  test 'no any report changes' do
    today_done       = build(:fund_operation, :done)
    earlier_pending  = build(:fund_operation, operation_date: 5.days.ago.to_date)
    earlier_canceled = build(:fund_operation, :canceled, operation_date: 5.days.ago.to_date)

    assert_equal false, today_done.any_reports_changes?
    assert_equal false, earlier_pending.any_reports_changes?
    assert_equal false, earlier_canceled.any_reports_changes?

    today_done.save
    earlier_pending.save
    earlier_canceled.save

    today_done.status = FundOperation::STATUS_CANCELED
    assert_equal false, today_done.any_reports_changes?

    earlier_pending.status = FundOperation::STATUS_DONE
    earlier_pending.operation_date = Date.current
    assert_equal false, earlier_pending.any_reports_changes?

    earlier_canceled.operation_date = Date.current
    assert_equal false, earlier_canceled.any_reports_changes?
  end

  test 'any report changes exist' do
    earlier_done     = build(:fund_operation, :done, operation_date: 5.days.ago.to_date)
    earlier_pending  = create(:fund_operation, operation_date: 5.days.ago.to_date)

    assert earlier_done.any_reports_changes?
    assert_equal false, earlier_pending.any_reports_changes?

    earlier_done.save
    earlier_done.reload

    earlier_pending.status = FundOperation::STATUS_DONE
    earlier_done.status    = FundOperation::STATUS_CANCELED

    assert earlier_done.any_reports_changes?
    assert earlier_pending.any_reports_changes?

    earlier_pending.save
    earlier_pending.reload
    earlier_done.save
    earlier_done.reload

    earlier_pending.operation_date = Date.current
    assert earlier_pending.any_reports_changes?
  end

  test 'belongs to investor' do
    assert build(:fund_operation).belongs_to_investor?
    assert_not build(:fund_operation, :instrument_operation).belongs_to_investor?
  end
end
