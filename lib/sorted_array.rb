class SortedArray < Array
  def initialize(*args, &sort_by)
    @sort_by = sort_by || Proc.new { |x, y| x <=> y }
    super(*args)
    sort!(&sort_by)
  end

  def insert(i, v)
    insert_before = bsearch_index { |x| @sort_by.call(x, v) == 1 }
    super(insert_before ? insert_before : -1, v)
  end

  def <<(v)
    insert(0, v)
  end

  alias push <<

  ["delete_at", "delete"].each do |method_name|
    module_eval %{
      def #{method_name}(*args)
        super
        sort!(&@sort_by)
      end
    }
  end

  def delete_first
    delete_at(0)
  end

end
