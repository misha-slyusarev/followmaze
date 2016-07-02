# encoding: utf-8
# frozen_string_literal: true

module MessageBroker
  # Exchange routes messages across clients. It also managing a
  # situation when there is no client to follow to. It then
  # creates virtual queues that are able to manage real followers
  class Exchange
    attr_reader :message_queues

    def initialize
      @message_queues = SortedArray.new { |x, y| x.id <=> y.id }
    end

    def convey(message)
      @current_message = message

      case @current_message.type
      when Message::Type::FOLLOW then subscribe
      when Message::Type::UNFOLLOW then unsubscribe
      when Message::Type::BROADCAST then broadcast
      when Message::Type::PRIVATE then send_private
      when Message::Type::STATUS then send_status
      end

    rescue NoQueueFound
      return unless Message::Type::FOLLOW == message.type
      # Sometimes there is no client to follow. In this case if
      # a subscriber with 'from' id exists, we want to create a
      # virtual queue for him to subscribe.
      # If there is no such a client, and 'to' exists, then just
      # send raw 'Follow' message out to the client with 'to' id
      if look_through_queues(@current_message.from)
        vmq = VirtualMessageQueue.new(message.to)
        vmq.followers << @current_message.from
        @message_queues << vmq
      else
        to_mq = look_through_queues(@current_message.to)
        to_mq.push(message.raw) unless to_mq.nil?
      end
    end

    private

    def subscribe
      to_mq = find_message_queue(@current_message.to)
      from_mq = find_message_queue(@current_message.from)
      to_mq.followers << from_mq.id
      to_mq.push(@current_message.raw)
    end

    def unsubscribe
      mq = find_message_queue(@current_message.to)
      mq.followers.delete(@current_message.from)
      if !mq.followers && mq.class == VirtualMessageQueue
        @message_queues.delete(mq)
      end
    end

    def broadcast
      @message_queues.each { |mq| mq.push(@current_message.raw) }
    end

    def send_private
      send_message(@current_message.to, @current_message.raw)
    end

    def send_status
      mq = find_message_queue(@current_message.from)
      mq.followers.each { |id| send_message(id, @current_message.raw) }
    end

    def send_message(id, body)
      mq = find_message_queue(id)
      mq.push(body)
    end

    def find_message_queue(id)
      mq = look_through_queues(id)
      mq || raise(NoQueueFound)
    end

    def look_through_queues(id)
      @message_queues.bsearch { |q| id - q.id }
    end
  end

  class NoQueueFound < StandardError
  end
end
