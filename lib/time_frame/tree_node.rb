# Encoding: utf-8
class TimeFrame
  class Tree
    # This is a helper class for the collection. It contains the node definition
    # for the used tree structues.
    class TreeNode
      include Comparable
      attr_reader :item
      def initialize(item, &block)
        @item = item
        @block = block
      end

      def time_frame
        @block.call(item)
      end

      def <=>(other)
        position = time_frame.min <=> other.time_frame.min
        return position unless position == 0
        time_frame.max <=> other.time_frame.max
      end

    #   def update_ancestor_relation(new_ancestor, side)
    #     @ancestor = new_ancestor
    #     new_ancestor.left_child = self if side == :left
    #     new_ancestor.right_child = self if side == :right
    #   end

    #   def update_child_frame(new_child_frame)
    #     min = [@child_time_frame.min, new_child_frame.min].min
    #     max = [@child_time_frame.max, new_child_frame.max].max
    #     @child_time_frame = TimeFrame.new(min: min, max: max)
    #     ancestor.update_child_frame(@child_time_frame) if ancestor
    #   end

    #   def continue_left_side_search_for_time?(time)
    #     left_child && left_child.child_time_frame.cover?(time)
    #   end

    #   def continue_left_side_search_for_time_frame?(interval)
    #     left_child &&
    #     left_child.child_time_frame.min <= interval.max &&
    #     left_child.child_time_frame.max >= interval.min
    #   end

    #   def continue_right_side_search_for_time?(time)
    #     right_child && right_child.child_time_frame.cover?(time)
    #   end

    #   def continue_right_side_search_for_time_frame?(interval)
    #     right_child &&
    #     right_child.child_time_frame.min <= interval.max &&
    #     right_child.child_time_frame.max >= interval.min
    #   end

    #   def children_frame
    #     min = left_child ? left_child.children_frame.min : time_frame.min
    #     max = right_child ? right_child.children_frame.max : time_frame.max
    #     @child_time_frame ||= TimeFrame.new(min: min, max: max)
    #   end
    end
  end
end
