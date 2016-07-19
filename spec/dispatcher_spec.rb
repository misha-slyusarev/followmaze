# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe MessageBroker::Dispatcher do
  let(:event_port) { instance_double(Integer, 'Event port') }
  let(:client_port) { instance_double(Integer, 'Client port') }
  let(:event_socket) { instance_double(Socket, 'Event socket')}
  let(:client_socket) { instance_double(Socket, 'Client socket')}

  let(:new_raw_message) { instance_double(String, 'New raw message') }
  let(:new_message) { instance_double(MessageBroker::Message, 'New message') }

  subject(:dispatcher) { MessageBroker::Dispatcher.new(event_port, client_port) }

  before do
    allow(TCPServer).to receive(:new).with(event_port).and_return(event_socket)
    allow(TCPServer).to receive(:new).with(client_port).and_return(client_socket)
    allow(event_socket).to receive(:gets).and_return(new_raw_message)
    allow(event_socket).to receive(:accept).and_return(event_socket)
    allow(event_socket).to receive(:set_encoding).with('UTF-8').and_return(event_socket)
    allow(MessageBroker::Message).to receive(:new).with(new_raw_message).and_return(new_message)
  end

  describe '#run' do

    context 'with incoming event' do
      before do
        allow(dispatcher).to receive(:each_socket_activity).and_yield(event_socket)
      end

      it 'handles new event' do
        expect(dispatcher).to receive(:handle).with(new_message)
        dispatcher.run
      end
    end

    context 'with incoming client connection' do
      let(:new_message_queue) { instance_double(MessageBroker::MessageQueue, 'New message queue')}

      before do
        allow(dispatcher).to receive(:each_socket_activity).and_yield(client_socket)
        allow(MessageBroker::MessageQueue).to receive(:new).with(client_socket).and_return(new_message_queue)
        allow(new_message_queue).to receive(:run)
        allow(new_message_queue).to receive(:id)
        allow(Thread).to receive(:new).and_yield
      end

      it 'handles new connection' do
        expect(new_message_queue).to receive(:run)
        dispatcher.run
      end
    end

    context 'with new event proceeding along the sequence' do
      let(:exchange) { instance_double(MessageBroker::Exchange, 'Exchange') }

      before do
        allow(MessageBroker::Exchange).to receive(:new).and_return(exchange)
        allow(dispatcher).to receive(:each_socket_activity).and_yield(event_socket)
        allow(new_message).to receive(:sequence).and_return(1)
        allow(exchange).to receive(:convey).with(new_message)
      end

      it 'sends it out right away' do
        expect(exchange).to receive(:convey).with(new_message)
        dispatcher.run
      end
    end

    context 'with new event out of sequence' do
      let(:exchange) { instance_double(MessageBroker::Exchange, 'Exchange') }

      before do
        allow(MessageBroker::Exchange).to receive(:new).and_return(exchange)
        allow(dispatcher).to receive(:each_socket_activity).and_yield(event_socket)
        allow(new_message).to receive(:sequence).and_return(2)
      end

      it 'put new event on hold' do
        expect(exchange).not_to receive(:convey).with(new_message)
        dispatcher.run
      end
    end
  end
end
