# encoding: utf-8
# frozen_string_literal: true
module MessageBroker
  class SortedArray < Array
    def initialize(*args, &sort_by)
      @sort_by = sort_by || proc { |x, y| x <=> y }
      super(*args)
      sort!(&sort_by)
    end

    def insert(_i, v)
      insert_before = bsearch_index { |x| @sort_by.call(x, v) == 1 }
      super(insert_before ? insert_before : -1, v)
    end

    def <<(v)
      insert(0, v)
    end

    alias push <<

    def delete_first
      delete_at(0)
    end
  end
end
