class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    puts 'Event source connected'
  end

  def run
    @socket.write('HELLO')
    @socket.close
  end
end
