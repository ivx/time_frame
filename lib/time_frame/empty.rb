class TimeFrame
  # Singleton class for the empty time frame object
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

    def &(_other)
      self
    end

    def overlaps?(_)
      false
    end

    def split_by_interval(_)
      []
    end

    def shift_by(_)
      fail TypeError, 'can\'t shift empty time frame'
    end

    def shift_to(_)
      fail TypeError, 'can\'t shift empty time frame'
    end

    def without(*_)
      []
    end

    def inspect
      'EMPTY'
    end
  end
end
