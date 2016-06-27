class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    @message_queues = []

    puts 'Event source connected'
  end

  def run
    @socket.puts('HELLO')

    begin
      loop do
        line = @socket.gets
        @message_queues.each { |mq| mq.push(line) } if @message_queues
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

  def queues
    @message_queues
  end
end
