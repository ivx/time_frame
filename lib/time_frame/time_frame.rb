# Encoding: utf-8

# Temporary disable class length cop.
# rubocop:disable Style/ClassLength

# The time frame class provides an specialized and enhanced range for time
# values.
class TimeFrame
  attr_reader :min, :max

  EMPTY = Empty.instance

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
    if rangy?(element)
      element.empty? || min <= element.min && element.max <= max
    else
      min <= element && element <= max
    end
  end

  def before?(item)
    case
    when rangy?(item)
      fail_if_empty item
      item.min > max
    else
      item > max
    end
  end

  def after?(item)
    case
    when rangy?(item)
      fail_if_empty item
      item.min < min
    else
      item < min
    end
  end

  def deviation_of(item)
    case
    when rangy?(item)
      fail_if_empty item
      [deviation_of(item.min), deviation_of(item.max)].min_by(&:abs)
    when cover?(item)
      0
    else
      [(item - min).abs, (item - max).abs].min
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
    other.max > min && other.min < max
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

  def without_frame(other)
    intersection = self & other

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

  def fail_if_empty(item)
    fail ArgumentError, 'time frame is empty' if item.respond_to?(:empty) &&
        item.empty?
  end

  def rangy?(item)
    item.respond_to?(:min) && item.respond_to?(:max)
  end

  def check_bounds(max, min)
    fail ArgumentError, 'min is greater than max.' if min > max
  end
end

# rubocop:enable Style/ClassLength
