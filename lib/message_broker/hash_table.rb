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
      index = get_index(entry.send(@key_method))
      @bins[index] ||= []
      @bins[index] << entry
    end

    def [](key)
      index = get_index(key)
      @bins[index] and @bins[index].detect { |e| e.send(@key_method) == key }
    end

    def delete(key)
      index = get_index(key)
      @bins[index] and @bins[index].delete_if { |e| e.send(@key_method) == key }
    end

    def each(&block)
      @bins.flatten.compact.each(&block)
    end

    private

    def get_index(key)
      key.hash % @bins_count
    end
  end
end
