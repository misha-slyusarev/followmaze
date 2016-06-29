require 'message_queue'
require 'message'
require 'pry'

class Router
  def initialize
    @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
  end

  def queues
    @message_queues
  end

  def convey(message)
    begin
      if message.sequence == 16918
        puts message.raw
        puts message.inspect
        puts Message::Type::BROADCAST == message.type
      end

      case message.type
      when Message::Type::FOLLOW
        puts 'F' if message.sequence == 16918
        mq = find_message_queue(message.to)
        mq.add_follower(message.from)
        mq.push(message.raw)
      when Message::Type::UNFOLLOW
        puts 'U' if message.sequence == 16918
        mq = find_message_queue(message.to)
        mq.remove_follower(message.from)
        if ! mq.followers && mq.class == VirtualMessageQueue
          @message_queues.delete(mq.id)
        end
      when Message::Type::BROADCAST
        @message_queues.each { |mq| mq.push(message.raw) }
      when Message::Type::PRIVATE
        puts 'P' if message.sequence == 16918
        send_message(message.to, message.raw)
      when Message::Type::STATUS
        puts 'S' if message.sequence == 16918
        mq = find_message_queue(message.from)
        mq.followers.each { |fid| send_message(fid, message.raw)}
      end
    rescue NoQueueFound
      if Message::Type::FOLLOW == message.type
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
