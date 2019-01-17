# frozen_string_literal: true
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 95
end

$LOAD_PATH.unshift File.expand_path('./lib', __FILE__)
require_relative '../autoload'
require 'rack/test'
require 'capybara/rspec'
require 'rack_session_access/capybara'

app_content = File.read(File.expand_path('../../config.ru', __FILE__))
Capybara.app = eval "Rack::Builder.new {( #{app_content}\n )}"


RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods
  #
  # config.expect_with :rspec do |expectations|
  #   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  # end
  #
  # config.mock_with :rspec do |mocks|
  #   mocks.verify_partial_doubles = true
  # end
  #
  # config.shared_context_metadata_behavior = :apply_to_host_groups
end
