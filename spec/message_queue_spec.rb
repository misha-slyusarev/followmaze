# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe MessageBroker::MessageQueue do
  let(:id_line) { String.new('123') }
  let(:message_line) { instance_double('String', "321|P|2|1\n") }

  let(:client_socket) { double('client_socket') }
  let(:socket) { double('instance_socket') }

  let(:queue) { instance_double('Queue') }
  let(:followers) { MessageBroker::SortedArray.new }

  before do
    allow(client_socket).to receive(:accept).with(no_args).and_return(socket)
    allow(socket).to receive(:set_encoding).with('UTF-8').and_return(socket)
    allow(socket).to receive(:gets).with(no_args).and_return(id_line)
    allow(id_line).to receive(:to_i).and_return(id_line.to_i)
    allow(Queue).to receive(:new).and_return(queue)
    allow(queue).to receive(:push).with(message_line)
  end

  subject(:message_queue) { MessageBroker::MessageQueue.new(client_socket) }

  it { is_expected.to have_attributes(id: id_line.to_i, followers: followers)}

  describe '#push' do

    it 'adds line to the queue' do
      expect(queue).to receive(:push).with(message_line)
      message_queue.push(message_line)
    end
  end

  describe '#run' do
    before do
      allow(queue).to receive(:pop).with(no_args).and_return(message_line)
      allow(socket).to receive(:puts).with(message_line)
      allow(socket).to receive(:close).with(no_args)
    end

    it 'gets line from queue and send it over to the socket' do
      expect(message_queue).to receive(:loop).and_yield
      expect(queue).to receive(:pop).with(no_args).and_return(message_line)
      expect(socket).to receive(:puts).with(message_line)

      message_thread = Thread.new { message_queue.run }
      message_thread.join
    end

  end
end

describe MessageBroker::VirtualMessageQueue do
  let(:id) { double('int') }
  let(:followers) { MessageBroker::SortedArray.new }

  subject { MessageBroker::VirtualMessageQueue.new(id) }

  it { is_expected.to have_attributes(id: id, followers: followers)}
end
