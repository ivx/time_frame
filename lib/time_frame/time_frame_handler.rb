class TimeFrame
  # This class tells the active_record predicate builder how to handle
  # time_frame classes when passed into a where-clause
  class Handler
    def call(column, time_frame)
      Arel::Nodes::Between.new(
        column,
        Arel::Nodes::And.new(children_by(time_frame))
      )
    end

    def children_by(time_frame)
      [
        Arel::Nodes.build_quoted(time_frame.min),
        Arel::Nodes.build_quoted(time_frame.max)
      ]
    end
  end
end

ActiveRecord::PredicateBuilder.register_handler(
  TimeFrame, TimeFrame::Handler.new
)
