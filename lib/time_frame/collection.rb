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
      build_tree(sorted) if @tree_nodes.any?
    end

    def each(&block)
      @tree_nodes.each do |node|
        block.call(node.item)
      end
    end

    def all_covering(time)
      all_matching { |element| element.cover? time }
    end

    def all_intersecting(time_frame)
      all_matching { |element| element.overlaps? time_frame }
    end

    private

    def all_matching(&matcher)
      [].tap do |result|
        add_matching(@root, result, &matcher) if any?
      end
    end

    def sort_nodes
      @tree_nodes.sort_by! do |item|
        [item.time_frame.min, item.time_frame.max]
      end
    end

    def build_tree(sorted)
      sort_nodes unless sorted
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

    def add_matching(node, result, &matcher)
      return unless node && matcher.call(node.child_time_frame)

      add_matching(node.left_child, result, &matcher)
      result << node.item if matcher.call(node.time_frame)
      add_matching(node.right_child, result, &matcher)
    end
  end
end
