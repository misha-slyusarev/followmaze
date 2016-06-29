require 'sorted_array'

class Router
  def initialize
    @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
  end

  def queues
    @message_queues
  end

  def convey(message)
    puts " -> #{message.type} from #{message.from} to #{message.to}"

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
    end
  end

private

  def send_message(id, body)
    message_queue = @message_queues.bsearch { |mq| id - mq.id } or raise NoQueueFound
    message_queue.push(body)
  end

  def find_message_queue(id)
    mq = @message_queues.bsearch { |mq| id - mq.id }
    mq or raise NoQueueFound
  end
end

class NoQueueFound < StandardError
end
