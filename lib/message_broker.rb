# encoding: utf-8
# frozen_string_literal: true
require 'message_broker/message_queue'
require 'message_broker/sorted_array'
require 'message_broker/dispatcher'
require 'message_broker/exchange'
require 'message_broker/message'

require 'socket'

module MessageBroker
  def self.start(event_port: 9090, client_port: 9099)
    dispatcher = Dispatcher.new event_port, client_port
    dispatcher.run
  end
end
