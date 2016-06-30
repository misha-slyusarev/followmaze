require 'sorted_array'
require 'exchange'
require 'message'

class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    @exchange = Exchange.new
    @messages_to_handle = SortedArray.new { |x, y| x.sequence <=> y.sequence }
    @last_sequence = 0

    puts 'Event source connected'
  end

  def run
    each_new_line do |raw|
      message = Message.new(raw)
      if message.sequence - 1 == @last_sequence
        @exchange.convey(message)
        @last_sequence = message.sequence

        while @messages_to_handle.any?
          next_sequence = @messages_to_handle.first.sequence
          break unless next_sequence - 1 == @last_sequence

          @exchange.convey(@messages_to_handle.first)
          @messages_to_handle.delete_first
          @last_sequence = next_sequence
        end
      else
        @messages_to_handle << message
      end
    end
  end

private

  def each_new_line(&block)
    loop do
      line = @socket.gets
      yield line unless line.nil? || line.empty?
    end
  rescue Interrupt
    puts "\nGot interrupted.."
  rescue SocketError => se
    puts "Got socket error: #{se}"
  rescue StandardError => er
    puts "Error: #{er}"
  ensure
    @socket.close
    puts 'Dispatcher stopped'
  end

  def add_queue(mq)
    @exchange.message_queues << mq
  end
end
