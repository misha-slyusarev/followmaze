require 'socket'
require 'uri'
require 'dispatcher'
require 'message_queue'

class MessageBroker
  def initialize(event_port: 9090, client_port: 9099)
    @event_socket = TCPServer.new(event_port)
    @event_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)

    @client_socket = TCPServer.new(client_port)
    @client_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)

    @descriptors = [@event_socket, @client_socket]

    puts 'MessageBroker started'
  end

  def run
    begin
      loop do
        next unless active_sockets = select(@descriptors, nil, nil, nil)

        active_sockets.first.each do |sock|
          if sock == @event_socket
            Thread.new { Dispatcher.new(sock).run }
          else
            Thread.new { MessageQueue.new(sock).run }
          end
        end
      end

    rescue Interrupt
      puts 'Got interrupted..'
    ensure
      @descriptors.each do |sock|
        sock.close if sock
      end

      puts 'MessageBroker stopped'
    end
  end
  
end
