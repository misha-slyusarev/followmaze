# encoding: utf-8
# frozen_string_literal: true

module MessageBroker
  # HashTable provides O(1) access to its elements
  class HashTable
    def initialize(key_method)
      @key_method = key_method
      @bins_count = 100
      @bins = Array.new
    end

    def <<(entry)
      index = bin_for(get_key(entry))
      @bins[index] ||= []
      @bins[index] << entry
    end

    def [](key)
      index = bin_for(key)
      return unless @bins[index]
      @bins[index].detect { |e| get_key(e) == key }
    end

    def each(&block)
      @bins.flatten.compact.each(&block)
    end

    private

    def bin_for(key)
      key.hash % @bins_count
    end

    def get_key(entry)
      @key_method ? entry.send(@key_method) : entry
    end
  end
end
