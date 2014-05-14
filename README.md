# TimeRange

## Description

The time range class provides an specialized and enhanced range for time values.

## Installation

`gem install time_frame`

## Usage

You can create a `TimeRange` instance by specifying `min` and `max`

```ruby
time_range = TimeRange.new(min: Time.now, max: Time.now + 1.day)
```

or just by specifying a `min` and `duration`

```ruby
time_range = TimeRange.new(min: Time.now, duration: 1.day)
```

Let's play around a bit:

```ruby
# Create a time range instance from today with duration of 1 day
time_range = TimeRange.new(min: Time.now, duration: 1.day)
# => 2014-05-07 14:58:47 +0200..2014-05-08 14:58:47 +0200

# Get the duration
time_range.duration
# => 86400.0 seconds

# Shift the whole time range by... let's say... 2 days!
later = time_range.shift_by(2.days)
# => 2014-05-09 14:58:47 +0200..2014-05-10 14:58:47 +0200

# Shifting can also be done in the other direction...
earlier = time_range.shift_by(-2.days)
# => 2014-05-05 14:58:47 +0200..2014-05-06 14:58:47 +0200

# Is another time covered by our time range?
my_time = Time.new(2014, 5, 7, 16)
time_range.cover?(my_time)
# => true

# Deviation to another time?
earlier_time = time_range.min - 1.day
later_time = time_range.max + 4.days
time_range.deviation_of(earlier_time)
# => -86400.0
time_range.deviation_of(later_time)
# => 345600.0
# No deviation expected here:
time_range.deviation_of(time_range.min + 20.minutes)
# => 0
# ... yay!

# Shifting to another time... duration remains:
time_range.shift_to(Time.new(2016, 1, 1))
# => 2016-01-01 00:00:00 +0100..2016-01-02 00:00:00 +0100

# Checking whether another time range overlaps:
other_range = TimeRange.new(
  min: time_range.min - 3.days,
  max: time_range.min + 40.minutes
)
time_range.overlaps?(other_range)
# => true

# Time range without another time range:
time_range = TimeRange.new(min: Time.new(2014, 5, 12), duration: 1.day)
# => 2014-05-12 00:00:00 +0200..2014-05-13 00:00:00 +0200
other = TimeRange.new(min: Time.new(2014, 5, 12, 19), duration: 10.minutes)
# => 2014-05-12 19:00:00 +0200..2014-05-12 19:10:00 +0200
time_range.without(other)
# => [2014-05-12 00:00:00 +0200..2014-05-12 19:00:00 +0200, 2014-05-12 19:10:00 +0200..2014-05-13 00:00:00 +0200]
another = other.shift_by(15.minutes)
# => 2014-05-12 19:15:00 +0200..2014-05-12 19:25:00 +0200
# You can also use an array for substraction:
time_range.without(*[other, another])
# => [2014-05-12 00:00:00 +0200..2014-05-12 19:00:00 +0200, 2014-05-12 19:10:00 +0200..2014-05-12 19:15:00 +0200, 2014-05-12 19:25:00 +0200..2014-05-13 00:00:00 +0200]

# Use of the mathematical &. The intersection is returned:
time_range = TimeRange.new(min: Time.new(2014), duration: 1.day)
# => 2014-01-01 00:00:00 +0100..2014-01-02 00:00:00 +0100
other_time_range = time_range.shift_by(12.hours)
# => 2014-01-01 12:00:00 +0100..2014-01-02 12:00:00 +0100
time_range & other_time_range
# => 2014-01-01 12:00:00 +0100..2014-01-02 00:00:00 +0100

```

These are the most common functionalities of the `TimeRange` class, but there is quite more to discover. If you have an array of time ranges, you can compute their union and pairwise intersection using `TimeRange.union` and `TimeRange.intersection`. For two sorted arrays of time ranges, you can traverse all overlaps of time ranges in the first array with time ranges in the second array in **linear time** using `TimeRange.each_overlap`.

```ruby

# each_overlap in a real life sample:

husband_at_home = [
  TimeRange.new(min: Time.new(2014, 2, 1), duration: 2.days),
  TimeRange.new(min: Time.new(2014, 5, 1), duration: 4.days),
  TimeRange.new(min: Time.new(2014, 7, 1), duration: 10.days)
]

mother_in_law_visits = [
  TimeRange.new(min: Time.new(2014, 2, 2), duration: 1.days),
  TimeRange.new(min: Time.new(2014, 7, 3), duration: 2.days)
]

TimeRange.each_overlap(mother_in_law_visits, husband_at_home) do |overlap|
  puts "Houston... we have a problem... from #{overlap.min} to #{overlap.max}"
end

```

## Does `TimeRange` inherit from `Range`?
No. Ruby's `Range` class is multi-purpose, it can hold contiuous values (like floats), as well as discrete values (like integers) and behaves differently according to their type. Instance methods like `#each` or `#size` just don't make sense for time values, the same is true for all methods provided by the `Enumerable` mixin.
