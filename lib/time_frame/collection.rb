# Encoding: utf-8

class TimeFrame
  # This collection supports the concept of interval trees to improve the
  # access speed to intervals (or objects containing intervals) intersecting
  # given time_frames or covering time elements
  class Collection
    include Enumerable
    delegate :size, to: :@tree_nodes
    attr_reader :tree_nodes, :root
    def initialize(item_list = [], &block)
      @block = block ? block : ->(item) { item }
      @tree = Tree.new
      item_list.each { |item| @tree.add(item, @block) }

      # sort_list(@tree_nodes) unless sorted
      # build_tree(0, @tree_nodes.size - 1)
      # @root = @tree_nodes[(@tree_nodes.size - 1) / 2]

      # # set recurvively all children time frames:
      # @root.children_frame
    end

    def each(&block)
      tree_nodes.each { |node| block.call(node.item) }
    end

    def all_covering(time)
      result = []
      add_covering(time, @root, result)
      result
    end

    def all_intersecting(time_frame)
      result = []
      add_intersecting(time_frame, @root, result)
      result
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
