class MessageQueue
  attr_writer :queue

  def initialize(client_socket)
    @socket = client_socket.accept
    @queue = Queue.new

    puts 'Client connected'
  end

  def run
    @socket.puts('HELLO')
  end

  def drop(message)
    @socket.puts(message)
    @socket.close
  end
end
