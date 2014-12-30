# Encoding: utf-8

# Temporary disable class length cop.
# rubocop:disable Metrics/ClassLength

# The time frame class provides an specialized and enhanced range for time
# values.
class TimeFrame
  attr_reader :min, :max

  EMPTY = Empty.instance

  def initialize(args)
    @min = args.fetch(:min)
    @max = args.fetch(:max) { @min + args.fetch(:duration) }
    check_bounds
    @max_float = @max.to_f
    @min_float = @min.to_f
  end

  def duration
    @duration ||= (@max_float - @min_float)
  end

  def ==(other)
    @min_float == other.min_float &&
      @max_float == other.max_float
  end

  def <=>(other)
    [@min_float, @max_float] <=> [other.min_float, other.max_float]
  end

  alias_method :eql?, :==

  def hash
    [min, max].hash
  end

  def cover?(element)
    if element.is_a?(TimeFrame)
      element.empty? ||
        @min_float <= element.min_float && element.max_float <= max_float
    else
      min_float <= element.to_f && element.to_f <= max_float
    end
  end

  def before?(item)
    case
    when item.is_a?(TimeFrame)
      fail_if_empty item
      item.min_float > max_float
    else
      item.to_f > max_float
    end
  end

  def after?(item)
    case
    when item.is_a?(TimeFrame)
      fail_if_empty item
      item.max_float < min_float
    else
      item.to_f < min_float
    end
  end

  def time_between(item)
    case
    when item.is_a?(TimeFrame)
      time_between_time_frame(item)
    when cover?(item)
      0
    else
      time_between_float(item.to_f)
    end
  end

  def empty?
    false
  end

  def self.union(time_frames, options = {})
    Uniter.new(time_frames, options).unite
  end

  def self.intersection(time_frames)
    time_frames.reduce(time_frames.first) do |intersection, time_frame|
      intersection & time_frame
    end
  end

  # Returns true if the interior intersect.
  def overlaps?(other)
    return false if other.duration == 0
    other.max_float > min_float && other.min_float < max_float
  end

  def &(other)
    return EMPTY if other.empty?
    new_min = [min, other.min].max
    new_max = [max, other.max].min
    new_min <= new_max ? TimeFrame.new(min: new_min, max: new_max) : EMPTY
  end

  def shift_by(duration)
    TimeFrame.new(min: @min + duration, duration: self.duration)
  end

  def shift_to(time)
    TimeFrame.new(min: time, duration: duration)
  end

  def without(*args)
    frames = args.select { |frame| overlaps?(frame) }
    frames = TimeFrame.union(frames)

    frames.reduce([self]) do |result, frame_to_exclude|
      last_frame = result.pop
      result + last_frame.without_frame(frame_to_exclude)
    end
  end

  def split_by_interval(interval)
    Splitter.new(self).split_by interval
  end

  def self.covering_time_frame_for(time_frames)
    CoveredFrame.new(time_frames).frame
  end

  def self.each_overlap(frames1, frames2)
    Overlaps.new(frames1, frames2).each do |first, second|
      yield(first, second)
    end
  end

  def inspect
    "#{min}..#{max}"
  end

  protected

  attr_reader :min_float, :max_float

  def without_frame(other)
    intersection = self & other

    result = []
    if intersection.min_float > min_float
      result << TimeFrame.new(min: min, max: intersection.min)
    end
    if intersection.max_float < max_float
      result << TimeFrame.new(min: intersection.max, max: max)
    end
    result
  end

  private

  def fail_if_empty(item)
    fail ArgumentError, 'time frame is empty' if item.respond_to?(:empty?) &&
                                                 item.empty?
  end

  def check_bounds
    fail ArgumentError, 'min is greater than max.' if min > max
  end

  def time_between_time_frame(time_frame)
    fail_if_empty time_frame
    [time_between(time_frame.min), time_between(time_frame.max)].min_by(&:abs)
  end

  def time_between_float(float_value)
    [(float_value - min_float).abs, (float_value - max_float).abs].min
  end
end

# rubocop:enable Metrics/ClassLength
