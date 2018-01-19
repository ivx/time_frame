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
