# Encoding: utf-8
class TimeFrame
  # Creates a union of many time_frame's. You can request a sorted collection by
  # the min Time value.
  class Uniter
    def initialize(time_frames, options = {})
      @time_frames = time_frames
      @sorted = options[:sorted]
    end

    def unite
      frames = @sorted ? @time_frames : @time_frames.sort_by(&:min)
      frames.each_with_object([]) do |frame, result|
        last_frame = result.last
        if last_frame && last_frame.cover?(frame.min)
          result[-1] = TimeFrame.new(min: last_frame.min, max: frame.max)
        else
          result << frame
        end
      end
    end
  end
end
