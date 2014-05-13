require_relative 'time_range'
class TimeRange
  module Splitter
    def split_by_interval(interval)
      time = @min
      max = @max
      time_ranges = []
      until time >= max
        time_old = time
        time += interval
        time_ranges << TimeRange.new(min: time_old, max: [time, max].min)
      end
      time_ranges
    end
  end
end
