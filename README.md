# TimeFrame

[![Gem Version](https://badge.fury.io/rb/time_frame.svg)](http://badge.fury.io/rb/time_frame)
[![Dependency Status](https://gemnasium.com/injixo/time_frame.svg)](https://gemnasium.com/injixo/time_frame)
[![Code Climate](https://codeclimate.com/github/injixo/time_frame.png)](https://codeclimate.com/github/injixo/time_frame)
[![Build Status](https://travis-ci.org/injixo/time_frame.svg?branch=master)](https://travis-ci.org/ivx/time_frame)

## Installation

`gem install time_frame`

## Usage

You can create a `TimeFrame` instance by specifying `min` and `max`

```ruby
time_frame = TimeFrame.new(min: Time.now, max: Time.now + 1.day)
```

or just by specifying a `min` and `duration`

```ruby
time_frame = TimeFrame.new(min: Time.now, duration: 1.day)
```

###Important:
TimeFrame doesn't support Date class.

## Let's play around a bit...

Create a time frame instance from today with duration of 1 day
```ruby
time_frame = TimeFrame.new(min: Time.now, duration: 1.day)
# => 2014-05-07 14:58:47 +0200..2014-05-08 14:58:47 +0200
```

Get the duration
```ruby
time_frame.duration
# => 86400.0 seconds
```

Shift the whole time frame by... let's say... 2 days!
```ruby
later = time_frame.shift_by(2.days)
# => 2014-05-09 14:58:47 +0200..2014-05-10 14:58:47 +0200
```

Shifting can also be done in the other direction...
```ruby
earlier = time_frame.shift_by(-2.days)
# => 2014-05-05 14:58:47 +0200..2014-05-06 14:58:47 +0200
```

Is another time covered by our time frame?
```ruby
my_time = Time.new(2014, 5, 7, 16)
time_frame.cover?(my_time)
# => true
```

Shifting to another time... duration remains:
```ruby
time_frame.shift_to(Time.new(2016, 1, 1))
# => 2016-01-01 00:00:00 +0100..2016-01-02 00:00:00 +0100
```

Checking whether another time frame overlaps:
```ruby
other_frame = TimeFrame.new(
  min: time_frame.min - 3.days,
  max: time_frame.min + 40.minutes
)
time_frame.overlaps?(other_frame)
# => true
```

Time frame without another time frame:
```ruby
time_frame = TimeFrame.new(min: Time.new(2014, 5, 12), duration: 1.day)
other = TimeFrame.new(min: Time.new(2014, 5, 12, 19), duration: 10.minutes)
time_frame.without(other)
# [2014-05-12 00:00:00 +0200..2014-05-12 19:00:00 +0200,
#  2014-05-12 19:10:00 +0200..2014-05-13 00:00:00 +0200]
```

You can also use without with many TimeFrame's:
```ruby
another = other.shift_by(15.minutes)
time_frame.without(other, another)
# [2014-05-12 00:00:00 +0200..2014-05-12 19:00:00 +0200,
#  2014-05-12 19:10:00 +0200..2014-05-12 19:15:00 +0200,
#  2014-05-12 19:25:00 +0200..2014-05-13 00:00:00 +0200]
```

Use of the mathematical &. The intersection is returned:
```ruby
time_frame = TimeFrame.new(min: Time.new(2014), duration: 1.day)
other_time_frame = time_frame.shift_by(12.hours)
time_frame & other_time_frame
# => 2014-01-01 12:00:00 +0100..2014-01-02 00:00:00 +0100
```

These are the most common functionalities of the `TimeFrame` class, but there is quite more to discover. If you have an array of time frames, you can compute their union and pairwise intersection using `TimeFrame.union` and `TimeFrame.intersection`. For two sorted arrays of time frames, you can traverse all overlaps of time frames in the first array with time frames in the second array in **linear time** using `TimeFrame.each_overlap`.

```ruby

# each_overlap in a real life sample:

husband_at_home = [
  TimeFrame.new(min: Time.new(2014, 2, 1), duration: 2.days),
  TimeFrame.new(min: Time.new(2014, 5, 1), duration: 4.days),
  TimeFrame.new(min: Time.new(2014, 7, 1), duration: 10.days)
]

mother_in_law_visits = [
  TimeFrame.new(min: Time.new(2014, 2, 2), duration: 1.days),
  TimeFrame.new(min: Time.new(2014, 7, 3), duration: 2.days)
]

TimeFrame.each_overlap(mother_in_law_visits, husband_at_home) do |overlap|
  puts "Houston... we have a problem... from #{overlap.min} to #{overlap.max}"
end

```

## Usage with ActiveRecord
When you want tu use TimeFrame with active record you need to define and initialize a PredicateHandler. Assuming you want to use this feature in a model called VogonPoen < ActiveRecord::Base you can do this as follows:
```ruby
class TimeFrame
  # This class tells the active_record predicate builder how to handle
  # time_frame classes when passed into a where-clause
  class PredicateBuilderHandler

    def initialize(model)
      @model = model
      model
        .predicate_builder
        .register_handler(TimeFrame, proc do |column, time_frame|
          column.in(time_frame.min..time_frame.max)
        end)

    end
  end
end

TimeFrame::PredicateBuilderHandler.new(VogonPoem)

poem_min = VogonPoem.create(written_at: time_frame.min)
poem_max = VogonPoem.create(written_at: time_frame.max)

result = VogonPoem.where(written_at: time_frame)

# The following specs will hold:

# expect(result.count).to eq 2
# expect(result.first).to eq poem_min
# expect(result.last).to eq poem_max
```

## Does `TimeFrame` inherit from `Range`?
No. Ruby's `Range` class is multi-purpose, it can hold contiuous values (like floats), as well as discrete values (like integers) and behaves differently according to their type. Instance methods like `#each` or `#size` just don't make sense for time values, the same is true for all methods provided by the `Enumerable` mixin.


## License

The [MIT License](http://opensource.org/licenses/MIT) (MIT)

Copyright (c) 2014 [InVision](http://www.invision.de)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
