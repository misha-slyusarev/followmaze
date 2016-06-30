require 'sorted_array'
require 'message'
require 'router'

class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    @router = Router.new
    @messages_to_route = SortedArray.new { |x, y| x.sequence <=> y.sequence }
    @last_sequence = 0

    puts 'Event source connected'
  end

  def run
    loop do
      raw_message = @socket.gets
      unless raw_message.nil? || raw_message.empty?
        message = Message.new(raw_message)

        if message.sequence - 1 == @last_sequence
          @router.convey(message)
          @last_sequence = message.sequence

          while @messages_to_route.any?
            next_sequence = @messages_to_route.first.sequence
            break unless next_sequence - 1 == @last_sequence

            @router.convey(@messages_to_route.first)
            @messages_to_route.delete_first
            @last_sequence = next_sequence
          end
        else
          @messages_to_route << message
        end
      end
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

  # TODO: remove message queue from the list
  #       when appropriate client drops off
  def add_queue(mq)
    @router.queues << mq
  end
end
