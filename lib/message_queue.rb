class MessageQueue
  def initialize(client_socket)
    @socket = client_socket.accept
    puts 'Client connected'
  end

  def run
    @socket.write('HELLO')
    @socket.close
  end
end
