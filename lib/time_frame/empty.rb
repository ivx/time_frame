# frozen_string_literal: true

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

    def time_between(_not_used)
      raise TypeError, 'time_between is undefined for empty time frame'
    end

    def &(_other)
      self
    end

    def overlaps?(_not_used)
      false
    end

    def split_by_interval(_not_used)
      []
    end

    def shift_by(_not_used)
      raise TypeError, 'can\'t shift empty time frame'
    end

    def shift_to(_not_used)
      raise TypeError, 'can\'t shift empty time frame'
    end

    def without(*_not_used)
      []
    end

    def inspect
      'EMPTY'
    end
  end
end
