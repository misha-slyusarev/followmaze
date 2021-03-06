# encoding: utf-8
# frozen_string_literal: true

module MessageBroker
  # Message parses raw line recieved from event sourse
  # and caries this information for futher processing
  class Message
    attr_reader :sequence, :type, :from, :to, :raw

    module Type
      FOLLOW = 1
      UNFOLLOW = 2
      BROADCAST = 3
      PRIVATE = 4
      STATUS = 5
    end

    def initialize(raw)
      sequence, type, from, to = raw.split('|')

      @type = get_type(type)
      @sequence = sequence.to_i
      @from = from.to_i
      @to = to.to_i
      @raw = raw
    end

    private

    def get_type(type)
      case type.strip
      when 'F' then Type::FOLLOW
      when 'U' then Type::UNFOLLOW
      when 'B' then Type::BROADCAST
      when 'P' then Type::PRIVATE
      when 'S' then Type::STATUS
      end
    end
  end
end
