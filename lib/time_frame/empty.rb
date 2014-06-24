class TimeFrame
  class Empty < TimeFrame
    include Singleton

    def duration
      0
    end

    def cover?(element)
      element == EMPTY
    end

    def empty?
      true
    end

    def deviation_of(element)
      element == EMPTY ? 0 : Float::INFINITY
    end

    def &(other)
      self
    end

    def overlaps?(other)
      false
    end

    def split_by_interval(interval)
      []
    end

    def shift_by(interval)
      fail TypeError.new('can\'t shift empty time frame')
    end

    def shift_to(time)
      fail TypeError.new('can\'t shift empty time frame')
    end

    def without(*args)
      []
    end

    def inspect
      'EMPTY'
    end
  end
end