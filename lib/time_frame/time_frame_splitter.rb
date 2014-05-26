# Encoding: utf-8
class TimeFrame
  # Provides a method to split a time frame by a given interval. It returns
  # an array which contains the intervals as TimeFrame instances.
  class Splitter
    def initialize(time_frame)
      @time_frame = time_frame
    end

    def split_by(interval)
      time = @time_frame.min
      max = @time_frame.max
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
