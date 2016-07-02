# encoding: utf-8
# frozen_string_literal: true

describe MessageBroker::Message do
  let(:follow_message) { "123|F|60|48\n" }
  let(:unfollow_message) { "123|U|60|48\n" }
  let(:broadcast_message) { "123|B\n" }
  let(:private_message) { "123|P|60|48\n" }
  let(:status_message) { "123|S|48\n" }

  let(:follow_message_sequence) {123}
  let(:follow_message_from) {60}
  let(:follow_message_to) {48}

  it 'parses message correctly' do
    message = MessageBroker::Message.new(follow_message)
    expect(message.sequence).to eq(follow_message_sequence)
    expect(message.from).to eq(follow_message_from)
    expect(message.to).to eq(follow_message_to)
  end

  it 'determines Follow message type' do
    message = MessageBroker::Message.new(follow_message)
    expect(message.type).to eq(MessageBroker::Message::Type::FOLLOW)
  end

  it 'determines Unfollow message type' do
    message = MessageBroker::Message.new(unfollow_message)
    expect(message.type).to eq(MessageBroker::Message::Type::UNFOLLOW)
  end

  it 'determines Broadcast message type' do
    message = MessageBroker::Message.new(broadcast_message)
    expect(message.type).to eq(MessageBroker::Message::Type::BROADCAST)
  end

  it 'determines Private message type' do
    message = MessageBroker::Message.new(private_message)
    expect(message.type).to eq(MessageBroker::Message::Type::PRIVATE)
  end

  it 'determines Status message type' do
    message = MessageBroker::Message.new(status_message)
    expect(message.type).to eq(MessageBroker::Message::Type::STATUS)
  end
end
