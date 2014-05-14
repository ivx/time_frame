class TimeFrame
  class Uniter
    def initialize(time_frames, options = {})
      @time_frames = time_frames
      @sorted = options[:sorted]
    end

    def unite
      ranges = @sorted ? @time_frames : @time_frames.sort_by(&:min)
      ranges.reduce([]) do |result, range|
        last_range = result.last
        if last_range && last_range.cover?(range.min)
          result[-1] = TimeFrame.new(min: last_range.min, max: range.max)
        else
          result << range
        end
        result
      end
    end
  end
end
