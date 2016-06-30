require 'message_queue'
require 'message'

class Exchange
  attr_reader :message_queues

  def initialize
    @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
  end

  def convey(message)
    begin
      case message.type
      when Message::Type::FOLLOW
        mq = find_message_queue(message.to)
        mq.followers << message.from
        mq.push(message.raw)
      when Message::Type::UNFOLLOW
        mq = find_message_queue(message.to)
        mq.followers.delete(message.from)
        if ! mq.followers && mq.class == VirtualMessageQueue
          @message_queues.delete(mq)
        end
      when Message::Type::BROADCAST
        @message_queues.each { |mq| mq.push(message.raw) }
      when Message::Type::PRIVATE
        send_message(message.to, message.raw)
      when Message::Type::STATUS
        mq = find_message_queue(message.from)
        mq.followers.each { |fid| send_message(fid, message.raw)}
      end
    rescue NoQueueFound
      if Message::Type::FOLLOW == message.type
        vmq = VirtualMessageQueue.new(message.to)
        vmq.followers << message.from
        @message_queues << vmq
      end
    end
  end

private

  def send_message(id, body)
    message_queue = @message_queues.bsearch { |mq| id - mq.id }
    message_queue.push(body) unless message_queue.nil?
  end

  def find_message_queue(id)
    mq = @message_queues.bsearch { |mq| id - mq.id }
    mq or raise NoQueueFound
  end
end

class NoQueueFound < StandardError
end
