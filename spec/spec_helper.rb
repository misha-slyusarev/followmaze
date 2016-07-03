# encoding: utf-8
# frozen_string_literal: true

require 'simplecov'
require 'factory_girl'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end

require 'message_broker'
