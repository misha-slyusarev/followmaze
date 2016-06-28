require 'sorted_array'

class MessageQueue
  attr_reader :id

  def initialize(client_socket)
    @followers = SortedArray.new
    @queue = Queue.new

    @socket = client_socket.accept
    @id = @socket.gets.to_i

    puts "Client #{@id} connected"
  end

  def run
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

  def add_follower(id)
    @followers << id
  end

  def remove_follower(id)
    index = @followers.bsearch { |x| x == id }
    @followers.splice(index, 1)
  end
end
