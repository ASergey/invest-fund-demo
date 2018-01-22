class InstrumentHashReport < ApplicationRecord
  include InstrumentHashConcern

  belongs_to :instrument_report

  validates :hash_code, uniqueness: { scope: :instrument_report_id, case_sensitive: false }

  def self.fetch_by_hash_code(instrument_report_id, hash_code)
    by_hash_code(hash_code).find_by(instrument_report_id: instrument_report_id)
  end
end
