# encoding: utf-8
# frozen_string_literal: true

module MessageBroker
  # Common functionality for both MessageQueue
  # and VirtualMessageQueue classes
  module MessageQueueCommon
    attr_reader :id
    attr_accessor :followers
  end

  # Waits for a message from Exchange to
  # pass it over to a client socket
  class MessageQueue
    include MessageQueueCommon

    def initialize(client_socket)
      @queue = Queue.new
      @socket = client_socket.accept.set_encoding('UTF-8')
      @id = @socket.gets.to_i
      @followers = SortedArray.new
    end

    def run
      loop do
        line = @queue.pop
        break if :exit == line
        @socket.puts(line)
      end
    ensure
      @socket.close
    end

    def push(line)
      @queue.push(line)
    end

    def shutdown
      @queue.push(:exit)
    end
  end

  # Handles followers of unexisted clients
  class VirtualMessageQueue
    include MessageQueueCommon

    def initialize(id)
      @id = id
      @followers = SortedArray.new
    end

    ["push", "shutdown"].each do |method_name|
      module_eval %{
        def #{method_name}(*args)
        end
      }
    end
  end

end
