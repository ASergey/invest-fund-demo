# include ActionDispatch::TestProcess

if ENV['TEST_COVERAGE']
  require 'simplecov'
  Bundler.require(:test_coverage)
  SimpleCov.start 'rails'

  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::RcovFormatter.new.format(result)
    end
  end

  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factories'
require 'mocha/setup'
require 'minitest/reporters'
require 'mocha/test_unit'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

if ENV['TEST_JUNIT']
  Minitest::Reporters.use! [Minitest::Reporters::JUnitReporter.new('test/reports/', true)]
else
  Minitest::Reporters.use!
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
