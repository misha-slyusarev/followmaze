require 'socket'
require 'uri'
require 'dispatcher'
require 'message_queue'

class MessageBroker
  def initialize(event_port: 9090, client_port: 9099)
    @event_socket = TCPServer.new(event_port)

    @client_socket = TCPServer.new(client_port)
    @client_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)

    @descriptors = [@event_socket, @client_socket]
    @dispatcher = nil

    puts 'MessageBroker started'
  end

  def run
    begin
      loop do
        next unless active_sockets = select(@descriptors, nil, nil, nil)

        active_sockets.first.each do |sock|
          if sock == @event_socket
            @dispatcher = Dispatcher.new(sock)
            Thread.new { @dispatcher.run }
          else
            mq = MessageQueue.new(sock)
            if @dispatcher
              @dispatcher.add_queue(mq)
              Thread.new { mq.run }
            else
              mq.drop
            end
          end
        end
      end

    rescue Interrupt
      puts 'Got interrupted..'
    ensure
      @descriptors.each { |sock| sock.close }
      puts 'MessageBroker stopped'
    end
  end

end
