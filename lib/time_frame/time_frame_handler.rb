class TimeFrame
  # This class tells the active_record predicate builder how to handle
  # time_frame classes when passed into a where-clause
  class Handler
    def call(column, time_frame)
      Arel::Nodes::Between.new(
        column,
        Arel::Nodes::And.new([time_frame.min, time_frame.max])
      )
    end
  end
end

ActiveRecord::PredicateBuilder.register_handler(
    TimeFrame, TimeFrame::Handler.new
  )
