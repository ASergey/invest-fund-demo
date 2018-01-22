class ConditionalValidationsValidModelTest
  include ActiveModel::Model
  include ConditionalValidations

  attr_accessor :field

  validates :field, presence: true, if: :validate_if_field_validation_enabled?
end

class ConditionalValidationsIvalidModelTest
  include ActiveModel::Model
  include ConditionalValidations

  attr_accessor :field

  validates :field, presence: true, if: :validate_if_error
end

class ConditionalValidationsTest < ActionController::TestCase
  test 'error' do
    obj = ConditionalValidationsIvalidModelTest.new(field: nil)
    assert_raises(NoMethodError) do
      obj.valid?
    end
  end

  test 'validate' do
    obj = ConditionalValidationsValidModelTest.new(field: nil)
    assert(obj.valid?)

    obj = ConditionalValidationsValidModelTest.new(field: nil)
    obj.validated_scopes = [:field_validation_enabled]
    assert_not(obj.valid?)
  end
end