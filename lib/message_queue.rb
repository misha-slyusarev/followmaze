require 'sorted_array'

module MessageQueueCommon
  attr_reader :id
  attr_reader :followers

  def add_follower(id)
    @followers << id
  end

  def remove_follower(id)
    index = @followers.bsearch { |x| id - x }
    @followers.delete(index)
  end
end

class VirtualMessageQueue
  include MessageQueueCommon

  def initialize(id)
    @id = id
    @followers = SortedArray.new
  end

  # In virtual queue we don't send
  # the message anywhere
  def push(line)
  end
end

class MessageQueue
  include MessageQueueCommon

  def initialize(client_socket)
    @queue = Queue.new
    @socket = client_socket.accept
    @id = @socket.gets.to_i
    @followers = SortedArray.new

    puts "Client #{@id} connected"
  end

  def run
    begin
      loop do
        line = @queue.pop
        puts line if @id == 792
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
end
