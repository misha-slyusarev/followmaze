class Message
  attr_reader :type, :from, :to, :raw

  def initialize(raw)
    @raw = raw
    @type, from, to = raw.split('|')[1, 3]
    @from = from.to_i
    @to = to.to_i
  end
end
