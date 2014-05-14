class TimeFrame
  module Splitter
    def split_by_interval(interval)
      time = @min
      max = @max
      time_frames = []
      until time >= max
        time_old = time
        time += interval
        time_frames << TimeFrame.new(min: time_old, max: [time, max].min)
      end
      time_frames
    end
  end
end
