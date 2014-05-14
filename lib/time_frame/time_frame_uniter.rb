class TimeRange
  class Uniter
    def initialize(time_ranges, options = {})
      @time_ranges = time_ranges
      @sorted = options[:sorted]
    end

    def unite
      ranges = @sorted ? @time_ranges : @time_ranges.sort_by(&:min)
      ranges.reduce([]) do |result, range|
        last_range = result.last
        if last_range && last_range.cover?(range.min)
          result[-1] = TimeRange.new(min: last_range.min, max: range.max)
        else
          result << range
        end
        result
      end
    end
  end
end
