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

  # Empty methods for compatibility with MessageQueue
  ["push", "drop"].each do |method_name|
    module_eval %{ def #{method_name}(*args); end }
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
        @socket.puts(line)
      end
    ensure
      @socket.close
      puts "MessageQueue #{@id} stopped"
    end
  end

  def drop()
    @socket.close
  end

  def push(line)
    @queue.push(line)
  end
end
