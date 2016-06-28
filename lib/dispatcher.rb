require 'router'

class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    @router = Router.new

    puts 'Event source connected'
  end

  def run
    @socket.puts('HELLO')

    begin
      loop do
        line = @socket.gets
        @router.broadcast(line)
        @router.send_message(10, line)
      end

    rescue Interrupt
      puts 'Got interrupted..'
    rescue SocketError => se
      puts "Got socket error: #{se}"
    rescue StandardError => er
      puts "Error: #{er}"
    ensure
      @socket.close
      puts 'Dispatcher stopped'
    end
  end

  def add_queue(mq)
    @router.queues << mq
  end
end
