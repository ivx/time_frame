class TimeRange
  class CoveredRange
    def initialize(time_ranges)
      @time_ranges = time_ranges
    end

    def range
      return nil unless @time_ranges.any?
      min = @time_ranges.min_by(&:min).min
      max = @time_ranges.max_by(&:max).max
      TimeRange.new(min: min, max: max)
    end
  end
end
