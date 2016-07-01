# encoding: utf-8
# frozen_string_literal: true
module MessageBroker
  class Exchange
    attr_reader :message_queues

    def initialize
      @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
    end

    def convey(message)
      case message.type

      when Message::Type::FOLLOW
        to_mq = find_message_queue(message.to)
        from_mq = find_message_queue(message.from)
        to_mq.followers << from_mq.id
        to_mq.push(message.raw)

      when Message::Type::UNFOLLOW
        mq = find_message_queue(message.to)
        mq.followers.delete(message.from)
        if !mq.followers && mq.class == VirtualMessageQueue
          @message_queues.delete(mq)
        end

      when Message::Type::BROADCAST
        @message_queues.each { |mq| mq.push(message.raw) }

      when Message::Type::PRIVATE
        send_message(message.to, message.raw)

      when Message::Type::STATUS
        mq = find_message_queue(message.from)
        mq.followers.each { |id| send_message(id, message.raw) }
      end

    rescue NoQueueFound
      return unless Message::Type::FOLLOW == message.type

      # If there is a reciever with 'from' id, then we want
      # to create a virtual queue for him to follow.
      #
      # If there is no, and 'to' exists, then just send raw
      # Follow message out to 'to' reciever
      if @message_queues.bsearch { |mq| message.from - mq.id }
        vmq = VirtualMessageQueue.new(message.to)
        vmq.followers << message.from
        @message_queues << vmq
      elsif to_mq
        to_mq.push(message.raw)
      end
    end

    private

    def send_message(id, body)
      mq = find_message_queue(id)
      mq.push(body)
    end

    def find_message_queue(id)
      mq = @message_queues.bsearch { |mq| id - mq.id }
      mq || raise(NoQueueFound)
    end
  end

  class NoQueueFound < StandardError
  end
end
