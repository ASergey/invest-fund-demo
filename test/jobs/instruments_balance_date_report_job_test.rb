require 'test_helper'

class InstrumentsBalanceDateReportJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test 'direct run job test' do
    instrument = create(:instrument)
    Services::CalcBalances::CalcInstrumentReport.expects(:build_since_date).with(2.days.ago.to_date, instrument.id)
    InstrumentsBalanceDateReportJob.perform_now(2.days.ago.to_date, instrument.id)
  end
end
