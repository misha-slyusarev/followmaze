require 'sorted_array'

class Router
  def initialize
    @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
  end

  def queues
    @message_queues
  end

  def convey(message)
    #puts " -> #{message.type} from #{message.from} to #{message.to}"

    case message.type
    when 'F'
      mq = @message_queues.bsearch { |mq| mq.id == message.to }
      mq.add_follower(message.from)
      mq.push(message.raw)
    when 'U'
      mq = @message_queues.bsearch { |mq| mq.id == message.to }
      mq.remove_follower(message.from)
    when 'B'
      @message_queues.each { |mq| mq.push(body) }
    when 'P'
      send_message(message.to, message.raw)
    when 'S'
      mq = @message_queues.bsearch { |mq| mq.id == message.from }
      mq.each_follower { |fid| send_message(fid, message.raw)}
    end
  end

private

  def send_message(id, body)
    mq = @message_queues.bsearch { |mq| mq.id == id }
    mq.push(body)
  end
end
