class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    @queues = []

    puts 'Event source connected'
  end

  def run
    @socket.puts('HELLO')
    @socket.close
  end

  def queues
    @queues
  end
end
