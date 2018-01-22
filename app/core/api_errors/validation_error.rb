class ApiErrors::ValidationError < StandardError
  attr_accessor :details

  def initialize(msg = 'Validation failed', details = nil)
    @details = details
    super(msg)
  end
end