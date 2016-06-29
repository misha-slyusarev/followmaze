require 'message_queue'

class Router
  def initialize
    @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
  end

  def queues
    @message_queues
  end

  def convey(message)
    begin
      case message.type
      when 'F'
        mq = find_message_queue(message.to)
        mq.add_follower(message.from)
        mq.push(message.raw)
      when 'U'
        mq = find_message_queue(message.to)
        mq.remove_follower(message.from)
      when 'B'
        @message_queues.each { |mq| mq.push(body) }
      when 'P'
        send_message(message.to, message.raw)
      when 'S'
        mq = find_message_queue(message.from)
        mq.followers.each { |fid| send_message(fid, message.raw)}
      end
    rescue NoQueueFound
      if 'F' == message.type
        vmq = VirtualMessageQueue.new(message.to)
        vmq.add_follower(message.from)
        @message_queues << vmq
      end
    end
  end

private

  def send_message(id, body)
    message_queue = find_message_queue(id)
    message_queue.push(body)
  end

  def find_message_queue(id)
    mq = @message_queues.bsearch { |mq| id - mq.id }
    mq or raise NoQueueFound
  end
end

class NoQueueFound < StandardError
end
