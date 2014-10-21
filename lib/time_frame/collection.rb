# Encoding: utf-8

class TimeFrame
  # This collection supports the concept of interval trees to improve the
  # access speed to intervals (or objects containing intervals) intersecting
  # given time_frames or covering time elements
  class Collection
    include Enumerable

    def initialize(item_list = [], sorted = false, &block)
      block ||= ->(item) { item }
      @tree_nodes = item_list.map do |item|
        TreeNode.new(item: item, &block)
      end
      return if none?
      sort_nodes unless sorted
      build_tree
    end

    def each(&block)
      @tree_nodes.each do |node|
        block.call(node.item)
      end
    end

    def all_covering(time)
      [].tap do |result|
        add_covering(time, @root, result) if any?
      end
    end

    def all_intersecting(time_frame)
      [].tap do |result|
        add_intersecting(time_frame, @root, result) if any?
      end
    end

    private

    def sort_nodes
      @tree_nodes.sort_by! do |item|
        [item.time_frame.min, item.time_frame.max]
      end
    end

    def build_tree
      build_sub_tree(0, @tree_nodes.size - 1)
      @root = @tree_nodes[(@tree_nodes.size - 1) / 2]
    end

    def build_sub_tree(lower, upper, ancestor = nil, side = nil)
      mid = (lower + upper) / 2
      node = @tree_nodes[mid]

      node.update_ancestor_relation(ancestor, side) if ancestor && side

      build_sub_tree(lower, mid - 1, node, :left) unless lower == mid
      build_sub_tree(mid + 1, upper, node, :right) unless upper == mid

      node.update_child_frame(node.child_time_frame) if lower == upper
    end

    def add_covering(time, node, result)
      search_left = node.continue_left_side_search_for_time?(time)
      search_right = node.continue_right_side_search_for_time?(time)

      add_covering(time, node.left_child, result) if search_left
      result << node.item if node.time_frame.cover?(time)
      add_covering(time, node.right_child, result) if search_right
    end

    def add_intersecting(time_frame, node, result)
      search_left = node.continue_left_side_search_for_time_frame?(time_frame)
      search_right = node.continue_right_side_search_for_time_frame?(time_frame)

      add_intersecting(time_frame, node.left_child, result) if search_left
      result << node.item if node.time_frame.overlaps? time_frame
      add_intersecting(time_frame, node.right_child, result) if search_right
    end
  end
end