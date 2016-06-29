
# TODO: reimplement insert and delete with bsearch

class SortedArray < Array
  def initialize(*args, &sort_by)
    @sort_by = sort_by || Proc.new { |x, y| x <=> y }
    super(*args)
    sort!(&sort_by)
  end

  def insert(i, v)
    insert_before = index(find { |x| @sort_by.call(x, v) == 1 })
    super(insert_before ? insert_before : -1, v)
  end

  def <<(v)
    insert(0, v)
  end

  alias push <<
  alias unshift <<

  ["collect!", "flatten!", "[]=", "delete"].each do |method_name|
    module_eval %{
      def #{method_name}(*args)
        super
        sort!(&@sort_by)
      end
    }
  end

  # Do nothing; reversing the array would disorder it.
  def reverse!
  end
end
