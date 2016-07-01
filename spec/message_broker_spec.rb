# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe MessageBroker do
  it 'has a version number' do
    expect(MessageBroker::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
