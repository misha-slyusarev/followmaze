module MessageBroker
  class Base
    def initialize(event_port: 9090, client_port: 9099)
      @event_socket = TCPServer.new(event_port)
      @client_socket = TCPServer.new(client_port)
      @client_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
      @descriptors = [@event_socket, @client_socket]
      @dispatcher = nil
    end

    def run
      each_new_connection do |socket|
        if socket == @event_socket && @dispatcher.nil?
          @dispatcher = Dispatcher.new(socket)
          Thread.new { @dispatcher.run }
        else
          mq = MessageQueue.new(socket)
          mq.drop if @dispatcher.nil?
          @dispatcher.add_queue(mq)
          Thread.new { mq.run }
        end
      end
    end

  private

    def each_new_connection(&block)
      loop do
        next unless active_sockets = select(@descriptors, nil, nil, nil)
        active_sockets.first.each { |socket| yield socket }
      end
    rescue Interrupt
    ensure
      @descriptors.each { |sock| sock.close }
    end
  end
end
