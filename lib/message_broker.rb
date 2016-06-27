require 'socket'
require 'uri'

class MessageBroker
  def run(event_port: 9090, client_port: 9099)
    begin
      @event_socket = TCPServer.new(event_port)
      @client_socket = TCPServer.new(client_port)

      loop do
        es = @event_socket.accept
        Thread.new(es, &method(:handle_event))

        cs = @client_socket.accept
        Thread.new(cs, &method(:handle_client))
      end

    # CTRL-C
    rescue Interrupt
      puts 'Got Interrupt..'
    # Ensure that we release the socket on errors
    ensure
      if @socket
        @socket.close
        puts 'Socked closed..'
      end
      puts 'Quitting.'
    end
  end

  def handle_event(publisher)
    puts 'Publisher connected'
    request_line = publisher.readline
    puts(request_line)

=begin
    verb    = request_line[/^\w+/]
    url     = request_line[/^\w+\s+(\S+)/, 1]
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
    uri     = URI::parse url

    # Show what got requested
    puts((" %4s "%verb) + url)

    to_server = TCPSocket.new(uri.host, (uri.port.nil? ? 80 : uri.port))
    to_server.write("#{verb} #{uri.path}?#{uri.query} HTTP/#{version}\r\n")

    content_len = 0

    loop do
      line = to_client.readline

      if line =~ /^Content-Length:\s+(\d+)\s*$/
        content_len = $1.to_i
      end

      # Strip message_broker headers
      if line =~ /^message_broker/i
        next
      elsif line.strip.empty?
        to_server.write("Connection: close\r\n\r\n")

        if content_len >= 0
          to_server.write(to_client.read(content_len))
        end

        break
      else
        to_server.write(line)
      end
    end

    buff = ""
    loop do
      to_server.read(4048, buff)
      to_client.write(buff)
      break if buff.size < 4048
    end

    # Close the sockets
    to_client.close
    to_server.close
=end

    publisher.close
  end

  def handle_client(client)
    puts 'Client connected'
    client.close
  end

end
