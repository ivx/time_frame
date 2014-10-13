# Encoding: utf-8
class Collection
  # This is a helper class for the collection. It contains the node definition
  # for the used tree structues.
  class TreeNode
    attr_accessor :max_child, :min_child, :left_child, :right_child
    attr_reader :item, :time_frame, :ancestor
    def initialize(args, &block)
      @item = args.fetch(:item)
      @time_frame = block.call(item)
      # if ancestor is nil, then tree_item is root node
      @ancestor = args.fetch(:ancestor, nil)
      @left_child = args.fetch(:left_child, nil)
      @right_child = args.fetch(:right_child, nil)

      # if block is given use it to get item's time frame
      @max_child = args.fetch(:max_child, @time_frame.max)
      @min_child = args.fetch(:max_child, @time_frame.min)
    end

    def update_ancestor_relation(new_ancestor, side)
      @ancestor = new_ancestor
      new_ancestor.left_child = self if side == :left
      new_ancestor.right_child = self if side == :right
    end

    def update_child_range(new_min_child, new_max_child)
      @min_child = [@min_child, new_min_child].min
      @max_child = [@max_child, new_max_child].max
      ancestor.update_child_range(min_child, max_child) if ancestor
    end

    def continue_left_side_search_for_time?(time)
      left_child &&
      time >= left_child.min_child && time <= left_child.max_child
    end

    def continue_left_side_search_for_time_frame?(interval)
      left_child &&
      left_child.min_child <= interval.max &&
      interval.min <= left_child.max_child
    end

    def continue_right_side_search_for_time?(time)
      right_child &&
      right_child.min_child <= time && time <= right_child.max_child
    end

    def continue_right_side_search_for_time_frame?(interval)
      right_child &&
      right_child.min_child <= interval.max &&
      interval.min <= right_child.max_child
    end
  end
end
