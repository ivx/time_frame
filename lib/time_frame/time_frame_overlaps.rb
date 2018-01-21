# Encoding: utf-8
class TimeFrame
  # Traverses all intersections of in the cross product of two arrays of
  # time_frames and yields the block for each pair (linear runtime)
  #
  # NOTE:
  # * requires each of the arrays to consist of pairwise disjoint elements
  # * requires each of the arrays to be sorted
  class Overlaps
    def initialize(array1, array2)
      @array1 = array1.reject(&:empty?)
      @array2 = array2.reject(&:empty?)
    end

    def each(&block)
      return [] if @array1.empty? || @array2.empty?
      yield_current_pair(&block) if current_pair_overlaps?
      while each_array_has_many_items?
        shift
        yield_current_pair(&block) if current_pair_overlaps?
      end
    end

    private

    def shift
      if @array2.one? ||
         @array1.size > 1 && @array1[1].min < @array2[1].min
        @array1.shift
      else
        @array2.shift
      end
    end

    def each_array_has_many_items?
      @array1.size > 1 || @array2.size > 1
    end

    def yield_current_pair
      yield @array1.first, @array2.first
    end

    def current_pair_overlaps?
      @array1.first.overlaps? @array2.first
    end
  end
end
