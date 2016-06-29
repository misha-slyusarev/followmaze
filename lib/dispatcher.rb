require 'message'
require 'router'

class Dispatcher
  def initialize(event_socket)
    @socket = event_socket.accept
    @router = Router.new

    puts 'Event source connected'
  end

  def run
    begin
      loop do
        raw_message = @socket.gets
        unless raw_message.nil? || raw_message.empty?
          message = Message.new(raw_message)
          @router.convey(message)
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
  end

  # TODO: remove message queue from the list when
  #       when appropriate client drops off
  def add_queue(mq)
    @router.queues << mq
  end
end
