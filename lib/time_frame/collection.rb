# Encoding: utf-8

class TimeFrame
  # This collection supports the concept of interval trees to improve the
  # access speed to intervals (or objects containing intervals) intersecting
  # given time_frames or covering time elements
  class Collection
    attr_reader :tree_nodes, :root
    def initialize(item_list = [], sorted = false, &block)
      @block = block ? block : ->(item) { item }
      @tree_nodes = item_list.map do |item|
        TreeNode.new(item: item, &@block)
      end

      sort_list(@tree_nodes) unless sorted
      build_tree(0, @tree_nodes.size - 1)
      @root = @tree_nodes[(@tree_nodes.size - 1) / 2]
    end

    def all_covering(time)
      result = []
      add_covering(time, @root, result)
      result.sort_by { |item | [@block.call(item).min, @block.call(item).max] }
    end

    def all_intersecting(time_frame)
      result = []
      add_intersecting(time_frame, @root, result)
      result.sort_by { |item | [@block.call(item).min, @block.call(item).max] }
    end

    private

    def sort_list(item_list)
      item_list.sort_by! do |item|
        [item.time_frame.min, item.time_frame.max]
      end
    end

    def build_tree(lower, upper, ancestor = nil, side = nil)
      mid = (lower + upper) / 2
      node = @tree_nodes[mid]

      node.update_ancestor_relation(ancestor, side) if ancestor && side

      build_tree(lower, mid - 1, node, :left) unless lower == mid
      build_tree(mid + 1, upper, node, :right) unless upper == mid

      node.update_child_frame(node.child_time_frame) if lower == upper
    end

    def add_covering(time, node, result)
      result << node.item if node.time_frame.cover?(time)
      if node.continue_left_side_search_for_time?(time)
        add_covering(time, node.left_child, result)
      end
      return unless node.continue_right_side_search_for_time?(time)
      add_covering(time, node.right_child, result)
    end

    def add_intersecting(time_frame, node, result)
      result << node.item unless (node.time_frame & time_frame).empty?
      if node.continue_left_side_search_for_time_frame?(time_frame)
        add_intersecting(time_frame, node.left_child, result)
      end
      return unless node.continue_right_side_search_for_time_frame?(time_frame)
      add_intersecting(time_frame, node.right_child, result)
    end
  end
end
