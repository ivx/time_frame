class TimeFrame
  class CoveredRange
    def initialize(time_frames)
      @time_frames = time_frames
    end

    def range
      return nil unless @time_frames.any?
      min = @time_frames.min_by(&:min).min
      max = @time_frames.max_by(&:max).max
      TimeFrame.new(min: min, max: max)
    end
  end
end
