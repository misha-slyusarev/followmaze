# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe MessageBroker::MessageQueue do
  let(:queue) { instance_double('Queue') }
  let(:message_line) { double('message_line') }
  let(:id_line) { double('message_line') }
  let(:client_socket) { double('client_socket') }
  let(:socket) { double('socket') }

  before do
    allow(client_socket).to receive(:accept).and_return(socket)
    allow(socket).to receive(:set_encoding).with('UTF-8').and_return(socket)
    allow(socket).to receive(:gets).and_return(id_line)
    allow(id_line).to receive(:to_i)
  end

  describe '#push' do
    before do
      allow(Queue).to receive(:new).and_return(queue)
      allow(queue).to receive(:push).with(message_line)
    end

    it 'adds line to the queue' do
      expect(queue).to receive(:push).with(message_line)
      MessageBroker::MessageQueue.new(client_socket).push(message_line)
    end
  end
end
