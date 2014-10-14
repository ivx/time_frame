# Encoding: utf-8
class Collection
  # This is a helper class for the collection. It contains the node definition
  # for the used tree structues.
  class TreeNode
    attr_accessor :left_child, :right_child, :child_time_frame
    attr_reader :item, :time_frame, :ancestor
    def initialize(args, &block)
      @item = args.fetch(:item)
      @time_frame = block.call(item)
      # if ancestor is nil, then tree_item is root node
      @ancestor = args.fetch(:ancestor, nil)
      @left_child = args.fetch(:left_child, nil)
      @right_child = args.fetch(:right_child, nil)

      # if block is given use it to get item's time frame
      @child_time_frame = @time_frame
    end

    def update_ancestor_relation(new_ancestor, side)
      @ancestor = new_ancestor
      new_ancestor.left_child = self if side == :left
      new_ancestor.right_child = self if side == :right
    end

    def update_child_frame(new_child_frame)
      min = [@child_time_frame.min, new_child_frame.min].min
      max = [@child_time_frame.max, new_child_frame.max].max
      @child_time_frame = TimeFrame.new(min: min, max: max)
      ancestor.update_child_frame(@child_time_frame) if ancestor
    end

    def continue_left_side_search_for_time?(time)
      left_child && left_child.child_time_frame.cover?(time)
    end

    def continue_left_side_search_for_time_frame?(interval)
      left_child &&
      left_child.child_time_frame.min <= interval.max &&
      left_child.child_time_frame.max >= interval.min
    end

    def continue_right_side_search_for_time?(time)
      right_child && right_child.child_time_frame.cover?(time)
    end

    def continue_right_side_search_for_time_frame?(interval)
      right_child &&
      right_child.child_time_frame.min <= interval.max &&
      right_child.child_time_frame.max >= interval.min
    end
  end
end
