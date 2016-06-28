class MessageQueue
  attr_reader :id

  def initialize(client_socket)
    @socket = client_socket.accept
    @id = 1 # should read from socket instead
    @queue = Queue.new

    puts 'Client connected'
  end

  def run
    @socket.puts('HELLO')

    begin
      loop do
        line = @queue.pop
        @socket.puts(line)
      end

    rescue Interrupt
      puts 'Got interrupted..'
    ensure
      @socket.close
      puts 'MessageQueue stopped'
    end
  end

  def drop(message)
    @socket.puts(message)
    @socket.close
  end

  def push(line)
    @queue.push(line)
  end

  def <=>(peer)
    id <=> peer.id
  end
end
