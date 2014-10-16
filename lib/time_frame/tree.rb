class TimeFrame
  # Binary tree class for searching purposes
  class Tree
    attr_accessor :ancestor, :left_child, :right_child
    attr_reader :item
    def initialize(ancestor = nil, &block)
      @block = block || -> (e) { e }
      @ancestor = ancestor
    end

    def add(new_item)
      tree_node = TreeNode.new(new_item) { |node| @block.call(node) }
      add_to_tree_place(tree_node)
      ancestor || self
    end

    def is_leaf?
      @left_child.empty? && @right_child.empty?
    end

    def empty?
      @item.nil?
    end

    def time_frame
      return TimeFrame::EMPTY unless item
      TimeFrame.new(
        min: min_item_left.item.time_frame.min,
        max: max_item_right.item.time_frame.max
      )
    end

    def height
      left_height = @left_child.empty? ? 0 : @left_child.height + 1
      right_height = @right_child.empty? ? 0 : @right_child.height + 1
      [left_height, right_height].max
    end

    protected

    def balance_ratio
      left = @left_child.empty? ? -1 : @left_child.height
      right = @right_child.empty? ? -1 : @right_child.height
      right - left
    end

    def rotate_left
      puts 'rotate left'
      current_tree_node = self
      new_tree_node = right_child
      current_ancestor = ancestor
      # fix relation of ancestor
      new_tree_node.ancestor = current_ancestor
      if current_ancestor
        if current_ancestor.left_child == current_tree_node
          current_ancestor.left_child = new_tree_node
        else
          current_ancestor.right_child = new_tree_node
        end
      end
      switch_child = new_tree_node.left_child
      switch_child.ancestor = current_tree_node
      current_tree_node.right_child = switch_child

      new_tree_node.left_child = current_tree_node
      current_tree_node.ancestor = new_tree_node
    end

    def rotate_right
      puts 'rotate right'
      current_tree_node = self
      new_tree_node = left_child
      current_ancestor = ancestor
      # fix relation of ancestor
      new_tree_node.ancestor = current_ancestor
      if current_ancestor
        if current_ancestor.right_child == current_tree_node
          current_ancestor.right_child = new_tree_node
        else
          current_ancestor.left_child = new_tree_node
        end
      end
      switch_child = new_tree_node.right_child
      switch_child.ancestor = current_tree_node
      current_tree_node.left_child = switch_child

      new_tree_node.right_child = current_tree_node
      current_tree_node.ancestor = new_tree_node
    end

    def add_to_tree_place(tree_node)
      return use_item_for_node(tree_node) unless item
      if tree_node <= item
        @left_child.add_to_tree_place(tree_node)
      else
        @right_child.add_to_tree_place(tree_node)
      end
    end

    def min_item_left
      return @left_child.min_item_left unless @left_child.empty?
      self
    end

    def max_item_right
      return @right_child.max_item_right unless @right_child.empty?
      self
    end

    def rebalance
      ratio = balance_ratio
      puts "ratio: #{ratio}"
      if ratio < -1
        rotate_right
      elsif ratio > 1
        rotate_left
      end
      ancestor.rebalance if ancestor
    end

    private

    def use_item_for_node(tree_node)
      @item = tree_node
      # set root of subtrees
      @left_child = Tree.new(self)
      @right_child = Tree.new(self)
      ancestor.rebalance if ancestor
    end
  end
end
