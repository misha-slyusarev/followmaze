module MessageBroker
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

      @type = case type.strip
        when 'F' then Type::FOLLOW
        when 'U' then Type::UNFOLLOW
        when 'B' then Type::BROADCAST
        when 'P' then Type::PRIVATE
        when 'S' then Type::STATUS
      end

      @sequence = sequence.to_i
      @from = from.to_i
      @to = to.to_i
      @raw = raw
    end
  end
end
