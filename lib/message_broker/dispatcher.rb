module MessageBroker
  class Dispatcher
    def initialize(event_port, client_port)
      @event_socket = TCPServer.new(event_port).accept
      @client_socket = TCPServer.new(client_port)
      @client_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
      @descriptors = [@event_socket, @client_socket]

      @messages_to_handle = SortedArray.new { |x, y| x.sequence <=> y.sequence }
      @exchange = Exchange.new
      @last_sequence = 0
    end

    def run
      each_socket_activity do |socket|
        if socket == @event_socket
          raise Interrupt if @event_socket.eof?

          line = @event_socket.gets
          next if line.nil? || line.empty?

          message = Message.new(line)
          if message.sequence - 1 == @last_sequence
            @exchange.convey(message)
            @last_sequence = message.sequence

            while @messages_to_handle.any?
              next_sequence = @messages_to_handle.first.sequence
              break unless next_sequence - 1 == @last_sequence

              @exchange.convey(@messages_to_handle.first)
              @messages_to_handle.delete_first
              @last_sequence = next_sequence
            end
          else
            @messages_to_handle << message
          end
        else
          mq = MessageQueue.new(socket)
          @exchange.message_queues << mq
          Thread.new { mq.run }
        end
      end
    end

  private

    def each_socket_activity(&block)
      loop do
        next unless active_sockets = select(@descriptors, nil, nil, nil)
        active_sockets.first.each { |socket| yield socket }
      end
    rescue Interrupt
      puts "Stop MessageBroker"
    rescue SocketError => se
      puts "Got socket error: #{se}"
    rescue StandardError => er
      puts "Error: #{er}"
    ensure
      @descriptors.each { |sock| sock.close }
    end
  end
end
