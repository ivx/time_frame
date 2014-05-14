# The time frame class provides an specialized and enhanced range for time
# values.
class TimeFrame
  include Splitter
  attr_reader :min, :max

  def initialize(args)
    min = args.fetch(:min)
    max = args.fetch(:max, nil) || min + args.fetch(:duration)
    check_bounds(max, min)
    @max = max
    @min = min
  end

  def duration
    (max - min).seconds
  end

  def ==(other)
    min == other.min &&
      max == other.max
  end

  def cover?(element)
    if element.respond_to?(:min) && element.respond_to?(:max)
      return min <= element.min && element.max <= max
    end
    min <= element && element <= max
  end

  def deviation_of(item)
    case
    when item.respond_to?(:min) && item.respond_to?(:max)
      [deviation_of(item.min), deviation_of(item.max)].min_by { |a| a.abs }
    when cover?(item)
      0
    when item < min
      item - min
    else
      item - max
    end
  end

  def empty?
    min == max
  end

  def self.union(time_frames, options = {})
    Uniter.new(time_frames, options).unite
  end

  def self.intersection(time_frames)
    time_frames.reduce(time_frames.first) do |intersection, time_frame|
      return unless intersection
      intersection & time_frame
    end
  end

  # Returns true if the interior intersect.
  def overlaps?(other)
    other.max > min && other.min < max
  end

  def &(other)
    new_min = [min, other.min].max
    new_max = [max, other.max].min
    TimeFrame.new(min: new_min, max: new_max) if new_min <= new_max
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

  def without_frame(other)
    intersection = self & other
    # this case is never used up to now (15.03.2013),
    # since without selects the values correctly
    return [self] unless intersection

    result = []
    if intersection.min > min
      result << TimeFrame.new(min: min, max: intersection.min)
    end
    if intersection.max < max
      result << TimeFrame.new(min: intersection.max, max: max)
    end
    result
  end

  private

  def check_bounds(max, min)
    fail ArgumentError, 'min is greater than max.' if min > max
  end
end
