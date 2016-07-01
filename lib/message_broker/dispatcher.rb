# encoding: utf-8
# frozen_string_literal: true

module MessageBroker
  # Dispatcher responsobilities are to accept client connections and create
  # separate units of work for them, handle messages from event source and
  # pass them to Exchange (in correct sequence) for futher processing
  class Dispatcher
    def initialize(event_port, client_port)
      @event_socket = TCPServer.new(event_port).accept.set_encoding('UTF-8')
      @client_socket = TCPServer.new(client_port)
      @descriptors = [@event_socket, @client_socket]

      @messages_to_handle = SortedArray.new { |x, y| x.sequence <=> y.sequence }
      @exchange = Exchange.new
      @last_sequence = 0
    end

    def run
      each_socket_activity do |socket|
        if socket == @event_socket
          line = @event_socket.gets
          handle(Message.new(line))
        else
          mq = MessageQueue.new(socket)
          @exchange.message_queues << mq
          Thread.new { mq.run }
        end
      end
    end

    private

    def handle(message)
      if message.sequence - 1 == @last_sequence
        @exchange.convey(message)
        @last_sequence = message.sequence
        handle_other_messages
      else
        @messages_to_handle << message
      end
    end

    def handle_other_messages
      while @messages_to_handle.any?
        next_sequence = @messages_to_handle.first.sequence
        break unless next_sequence - 1 == @last_sequence

        @exchange.convey(@messages_to_handle.first)
        @messages_to_handle.delete_first
        @last_sequence = next_sequence
      end
    end

    def each_socket_activity
      loop do
        select(@descriptors, nil, nil, nil).first.each do |socket|
          raise Interrupt if socket == @event_socket && socket.eof?
          yield socket
        end
      end
    rescue Interrupt
      puts 'Done'
    rescue => er
      puts "Error: #{er}"
    ensure
      @descriptors.each(&:close)
    end
  end
end
