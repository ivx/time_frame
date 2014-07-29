# Encoding: utf-8
class TimeFrame
  # Creates a union of many time_frame's. You can request a sorted collection by
  # the min Time value.
  class Uniter
    def initialize(time_frames, options = {})
      @time_frames = time_frames.reject(&:empty?)
      @sorted = options[:sorted]
    end

    def unite
      frames = @sorted ? @time_frames : @time_frames.sort_by(&:min)
      frames.each_with_object([]) do |next_time_frame, result|
        last_time_frame = result.last
        if last_time_frame && last_time_frame.cover?(next_time_frame.min)
          max = [last_time_frame.max, next_time_frame.max].max
          result[-1] = TimeFrame.new(min: last_time_frame.min, max: max)
        else
          result << next_time_frame
        end
      end
    end
  end
end
