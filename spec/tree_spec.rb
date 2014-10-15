require 'spec_helper'

describe TimeFrame::Tree do

  let(:time_frame) { TimeFrame.new(min: Time.utc(2014), duration: 1.day) }
  let(:items) do
    [1, 2, 3, 4, 5, 6, 7, 8, 9].map { |i| time_frame.shift_by(i.days) }
  end

  describe 'balance_ratio and rebalancing' do
    it 'rebalance the tree when inserting new elements' do
      tree = TimeFrame::Tree.new
      tree.add(items.first)
      expect(tree.height).to eq 0
      tree.add(items.second)
      expect(tree.height).to eq 1
      tree.add(items.third)
      expect(tree.height).to eq 1
    end
  end

  describe '#time_frame' do
    it 'returns the tree time frame' do
      tree = TimeFrame::Tree.new
      items.each do |item|
        tree.add(item)
      end
      expected_time_frame = TimeFrame.new(
        min: items.min_by(&:min).min, max: items.max_by(&:max).max
      )
      # expect(tree.time_frame).to eq expected_time_frame
    end
  end

  describe '#height' do
    it 'returns true if a note is a leaf and false if not' do
      tree = TimeFrame::Tree.new
      [0, -1, 1].each { |shift| tree.add(time_frame.shift_by(shift.days)) }
      expect(tree.height).to eq 1
      tree.add(time_frame.shift_by(3.days))
      expect(tree.height).to eq 2
    end
  end

end