# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe MessageBroker do
  it 'has a version number' do
    expect(MessageBroker::VERSION).not_to be nil
  end

  describe '#start' do
    let(:dispatcher) { instance_double(MessageBroker::Dispatcher) }

    it 'creates new Dispatcher' do
      expect(MessageBroker::Dispatcher).to receive(:new).and_return(dispatcher)
      expect(dispatcher).to receive(:run)

      MessageBroker.start
    end
  end
end
