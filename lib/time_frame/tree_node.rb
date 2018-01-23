
# frozen_string_literal: true

class TimeFrame
  class Collection
    # This is a helper class for the collection. It contains the node definition
    # for the used tree structues.
    class TreeNode
      attr_accessor :left_child, :right_child, :child_time_frame
      attr_reader :item, :time_frame, :ancestor
      def initialize(args)
        @item = args.fetch(:item)
        @time_frame = yield(item)
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
        ancestor&.update_child_frame(@child_time_frame)
      end
    end
  end
end
