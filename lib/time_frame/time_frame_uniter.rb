class TimeFrame
  class Uniter
    def initialize(time_frames, options = {})
      @time_frames = time_frames
      @sorted = options[:sorted]
    end

    def unite
      frames = @sorted ? @time_frames : @time_frames.sort_by(&:min)
      frames.reduce([]) do |result, frame|
        last_frame = result.last
        if last_frame && last_frame.cover?(frame.min)
          result[-1] = TimeFrame.new(min: last_frame.min, max: frame.max)
        else
          result << frame
        end
        result
      end
    end
  end
end
