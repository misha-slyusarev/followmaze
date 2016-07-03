# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe MessageBroker::Exchange do

  let(:message_queue) { instance_double('MessageBroker::MessageQueue', 'Client')}

  let(:follow_raw_message) { double('Follow raw message') }
  let(:unfollow_raw_message) { double('Unfollow raw message') }
  let(:broadcast_raw_message) { double('Broadcast raw message') }
  let(:private_raw_message) { double('Private raw message') }
  let(:status_raw_message) { double('Status raw message') }

  let(:from_id) { 1 }
  let(:to_id) { 2 }

  subject(:exchange) { MessageBroker::Exchange.new }

  before do
    allow(message_queue).to receive(:id).and_return(to_id)
    exchange.message_queues << message_queue
  end

  describe '#convey' do

    context 'getting Follow message' do
      let(:follow_message) { instance_double('MessageBroker::Message', 'Follow message') }

      before do
        allow(follow_message).to receive(:type).and_return(MessageBroker::Message::Type::FOLLOW)
        allow(follow_message).to receive(:raw).and_return(follow_raw_message)
        allow(follow_message).to receive(:from).and_return(from_id)
        allow(follow_message).to receive(:to).and_return(to_id)

        allow(message_queue).to receive(:push).with(follow_raw_message)
      end

      it 'delivers it properly' do
        expect(message_queue).to receive(:push).with(follow_raw_message)
        
        exchange.convey(follow_message)
      end
    end

    # context 'getting Unfollow message' do
    #   before { exchange.convey(unfollow_message) }
    #   it 'delivers it properly' do
    #   end
    # end
    #
    # context 'getting Broadcast message' do
    #   before { exchange.convey(broadcast_message) }
    #   it 'delivers it properly' do
    #     exchange.convey(broadcast_message)
    #   end
    # end
    #
    # context 'getting Private message' do
    #   before { exchange.convey(private_message) }
    #   it 'delivers it properly' do
    #   end
    # end
    #
    # context 'getting Status message' do
    #   before { exchange.convey(status_message) }
    #   it 'delivers it properly' do
    #   end
    # end
  end
end