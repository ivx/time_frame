require 'spec_helper'

describe TimeRange do
  let(:time) { Time.zone.local(2012) }
  let(:duration) { 2.hours }

  describe '#initialize' do
    context 'when given two times' do
      context 'and min is smaller than max' do
        subject { TimeRange.new(min: time, max: time + duration) }

        describe '#min' do
          subject { super().min }
          it { should eq time }
        end

        describe '#max' do
          subject { super().max }
          it { should eq time + duration }
        end
      end
      context 'and max is smaller than min' do
        specify do
          expect do
            TimeRange.new(min: time, max: time - 1.day)
          end.to raise_error(ArgumentError)
        end
      end
      context 'which are equal' do
        subject { TimeRange.new(min: time, max: time) }

        describe '#min' do
          subject { super().min }
          it { should eq time }
        end

        describe '#max' do
          subject { super().max }
          it { should eq time }
        end
      end
    end

    context 'when time and duration is given' do
      context ' and duration is positive' do
        subject { TimeRange.new(min: time, duration: 1.hour) }

        describe '#min' do
          subject { super().min }
          it { should eq time }
        end

        describe '#max' do
          subject { super().max }
          it { should eq time + 1.hour }
        end
      end
      context 'and duration is negative' do
        let(:invalid_t_r) { TimeRange.new(min: time, duration: - 1.hour) }
        specify { expect { invalid_t_r }.to raise_error }
      end
      context 'and duration is 0' do
        subject { TimeRange.new(min: time, duration: 0.hour) }

        describe '#min' do
          subject { super().min }
          it { should eq time }
        end

        describe '#max' do
          subject { super().max }
          it { should eq time }
        end
      end
      context 'and time range covers a DST shift' do
        let(:time) do
          Time.use_zone('Europe/Berlin') { Time.zone.local(2013, 10, 27) }
        end
        subject { TimeRange.new(min: time, duration: 1.day) }

        describe '#min' do
          subject { super().min }
          it { should eq time }
        end

        describe '#max' do
          subject { super().max }
          it { should eq time + 25.hours }
        end
      end
    end
  end

  describe '#duration' do
    context 'when borders are different' do
      subject { TimeRange.new(min: time, duration: 2.hours).duration }
      it { should eq 2.hours }
    end
    context 'when borders are equal' do
      subject { TimeRange.new(min: time, max: time).duration }
      it { should eq 0 }
    end
    context 'when time range containts a DST shift' do
      it 'should gain 1 hour on summer -> winter shifts' do
        Time.use_zone('Europe/Berlin') do
          time_range = TimeRange.new(min: Time.zone.local(2013, 10, 27),
                                     max: Time.zone.local(2013, 10, 28))
          expect(time_range.duration).to eq 25.hours
        end
      end
      it 'should lose 1 hour on winter -> summer shifts' do
        Time.use_zone('Europe/Berlin') do
          time_range = TimeRange.new(min: Time.zone.local(2013, 3, 31),
                                     max: Time.zone.local(2013, 4, 1))
          expect(time_range.duration).to eq 23.hours
        end
      end
    end
  end

  describe '#==' do
    let(:range) { TimeRange.new(min: time, duration: 2.hours) }
    context 'when borders are equal' do
      let(:other) { TimeRange.new(min: time, duration: 2.hours) }
      subject { range == other }
      it { should be_true }
    end
    context 'when min value is different' do
      let(:other) do
        TimeRange.new(min: time - 1.hour, max: time + 2.hours)
      end
      subject { range == other }
      it { should be_false }
    end
    context 'when max value is different' do
      let(:other) { TimeRange.new(min: time, duration: 3.hours) }
      subject { range == other }
      it { should be_false }
    end
  end

  describe '#cover?' do
    let(:range) { TimeRange.new(min: time, duration: 4.hours) }
    context 'when argument is a Time instance' do
      context 'and its covered' do
        context 'and equal to min' do
          subject { range.cover?(range.min) }
          it { should be_true }
        end
        context 'and equal to max' do
          subject { range.cover?(range.max) }
          it { should be_true }
        end
        context 'and is an inner value' do
          subject { range.cover?(range.min + 1.hour) }
          it { should be_true }
        end
      end
      context 'and its not covered' do
        context 'and smaller than min' do
          subject { range.cover?(range.min - 1.hour) }
          it { should be_false }
        end
        context 'and greater than max' do
          subject { range.cover?(range.max + 5.hours) }
          it { should be_false }
        end
      end
    end
    context 'when argument is a TimeRange' do
      context 'and its covered' do
        context 'and they have the same min value' do
          let(:other) { TimeRange.new(min: range.min, duration: 2.hours) }
          subject { range.cover?(other) }
          it { should be_true }
        end
        context 'and they have the same max value' do
          let(:other) do
            TimeRange.new(min: range.min + 1.hour, max: range.max)
          end
          subject { range.cover?(other) }
          it { should be_true }
        end
        context 'and it is within the interior of self' do
          let(:other) do
            TimeRange.new(min: range.min + 1.hour, max: range.max - 1.hour)
          end
          subject { range.cover?(other) }
          it { should be_true }
        end
        context 'and are equal' do
          let(:other) { range.clone }
          subject { range.cover?(other) }
          it { should be_true }
        end
      end
      context 'and it is not covered' do
        context 'and other is left of self' do
          let(:other) { range.shift_by(-5.hours) }
          subject { range.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps left hand side' do
          let(:other) { range.shift_by(-1.hour) }
          subject { range.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps left hand side at the border only' do
          let(:other) { range.shift_by(-range.duration) }
          subject { range.cover?(other) }
          it { should be_false }
        end
        context 'and other is right of self' do
          let(:other) { range.shift_by(5.hours) }
          subject { range.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps right hand side' do
          let(:other) { range.shift_by(1.hours) }
          subject { range.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps right hand side at the border only' do
          let(:other) { range.shift_by(range.duration) }
          subject { range.cover?(other) }
          it { should be_false }
        end
      end
    end
  end

  describe '#deviation_of' do
    let(:time_range) do
      TimeRange.new(min: Time.zone.local(2012), duration: 2.days)
    end
    context 'when providing a time object' do
      describe 'when self covers time' do
        context 'and time equals min' do
          let(:time) { time_range.min }
          subject { time_range.deviation_of(time) }
          it { should eq 0.minutes }
        end
        context 'and time equals max' do
          let(:time) { time_range.max }
          subject { time_range.deviation_of(time) }
          it { should eq 0.minutes }
        end
        context 'and time is an interior point of self' do
          let(:time) { time_range.min + (time_range.duration / 2.0) }
          subject { time_range.deviation_of(time) }
          it { should eq 0.minutes }
        end
      end
      context 'when self do not cover time' do
        context 'and time is smaller than the left bound' do
          let(:time) { time_range.min - 42.hours - 42.minutes }
          subject { time_range.deviation_of(time) }
          it { should eq(-42.hours - 42.minutes) }
        end
        context 'and time is greater than the right bound' do
          let(:time) { time_range.max + 42.hours + 42.minutes }
          subject { time_range.deviation_of(time) }
          it { should eq 42.hours + 42.minutes }
        end
      end
    end
    context 'when providing a time_range' do
      describe 'when self overlaps other' do
        context 'and its partly' do
          let(:other) { time_range.shift_by(time_range.duration / 2) }
          subject { time_range.deviation_of(other) }
          it { should eq 0.minutes }
        end
        context 'and time equals max' do
          let(:other) { time_range }
          subject { time_range.deviation_of(other) }
          it { should eq 0.minutes }
        end
        context 'and other lies in the interior of self' do
          let(:other) do
            TimeRange.new(min: time_range.min + 1.hour, duration: 1.hour)
          end
          subject { time_range.deviation_of(other) }
          it { should eq 0.minutes }
        end
      end
      context 'when self do not cover time' do
        context 'and time is smaller than the left bound' do
          let(:other) { time_range.shift_by(-2.days - 42.seconds) }
          subject { time_range.deviation_of(other) }
          it { should eq(-42.seconds) }
        end
        context 'and time is greater than the right bound' do
          let(:other) { time_range.shift_by(2.days + 42.seconds) }
          subject { time_range.deviation_of(other) }
          it { should eq 42.seconds }
        end
      end
    end
  end

  describe '#split_to_interval' do
    let(:time_range) do
      TimeRange.new(min: Time.zone.local(2012), duration: 1.day)
    end
    context 'when time range duration is divisible by interval' do
      context 'and interval length equals duration' do
        subject { time_range.split_by_interval(1.day) }
        it { should eq [time_range] }
      end
      context 'and interval is smaller than duration' do
        let(:first_time_range) do
          TimeRange.new(min: time_range.min, duration: 12.hours)
        end
        subject { time_range.split_by_interval(12.hours) }
        it do
          should eq [first_time_range, first_time_range.shift_by(12.hours)]
        end
      end
      context 'and range starts at a time, not divisible by interval' do
        let(:other_time_range) do
          TimeRange.new(
            min: Time.zone.local(2012) + 1.minute,
            duration: 1.day
          )
        end
        let(:first_time_range) do
          TimeRange.new(min: other_time_range.min, duration: 12.hours)
        end
        subject { other_time_range.split_by_interval(12.hours) }
        it do
          should eq [first_time_range, first_time_range.shift_by(12.hours)]
        end
      end
    end
    context 'when time range duration is not divisible by interval' do
      let(:expected) do
        [
          TimeRange.new(min: time_range.min, duration: 18.hours),
          TimeRange.new(min: time_range.min + 18.hours, duration: 6.hours)
        ]
      end
      subject { time_range.split_by_interval(18.hours) }
      it { should eq expected }
    end
  end

  describe '#empty?' do
    context 'when min equals max' do
      subject { TimeRange.new(min: time, max: time) }
      it { should be_empty }
    end

    context 'when max is greater than min' do
      subject { TimeRange.new(min: time, duration: 1.day) }
      it { should_not be_empty }
    end
  end

  describe '.union' do

    context 'when given an empty array' do
      subject { TimeRange.union([]) }
      it { should eq [] }
    end

    context 'when given a single time range' do
      let(:range) { TimeRange.new(min: time, duration: 1.hour) }
      subject { TimeRange.union([range]) }
      it { should eq [range] }
    end

    context 'when getting single element it returns a dup' do
      let(:ranges) { [TimeRange.new(min: time, duration: 1.hour)] }
      subject { TimeRange.union(ranges) }
      it { should_not equal ranges }
    end

    context 'when given time ranges' do
      context 'in order' do
        context 'and no sorted flag is provided' do
          context 'that are overlapping' do
            let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
            let(:range2) { range1.shift_by(1.hour) }
            let(:expected) do
              [TimeRange.new(min: range1.min, max: range2.max)]
            end
            subject { TimeRange.union([range1, range2]) }
            it { should eq expected }
          end
          context 'that are disjoint' do
            let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
            let(:range2) { range1.shift_by(3.hours) }
            subject { TimeRange.union([range1, range2]) }
            it { should eq [range1, range2] }
          end
          context 'that intersect at their boundaries' do
            let(:range1) { TimeRange.new(min: time, duration: + 2.hour) }
            let(:range2) { range1.shift_by(range1.duration) }
            let(:expected) do
              [TimeRange.new(min: range1.min, max: range2.max)]
            end
            subject { TimeRange.union([range1, range2]) }
            it { should eq expected }
          end
        end
        context 'and the sorted flag is provided' do
          context 'that are overlapping' do
            let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
            let(:range2) { range1.shift_by(1.hour) }
            let(:expected) do
              [TimeRange.new(min: range1.min, max: range2.max)]
            end
            subject { TimeRange.union([range1, range2], sorted: true) }
            it { should eq expected }
          end
          context 'that are disjoint' do
            let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
            let(:range2) { range1.shift_by(3.hours) }
            subject { TimeRange.union([range1, range2], sorted: true) }
            it { should eq [range1, range2] }
          end
          context 'that intersect at their boundaries' do
            let(:range1) { TimeRange.new(min: time, duration: + 2.hour) }
            let(:range2) { range1.shift_by(range1.duration) }
            let(:expected) do
              [TimeRange.new(min: range1.min, max: range2.max)]
            end
            subject { TimeRange.union([range1, range2], sorted: true) }
            it { should eq expected }
          end
        end
      end
      context 'not in order' do
        context 'that are overlapping' do
          let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
          let(:range2) { range1.shift_by(1.hour) }
          subject { TimeRange.union([range2, range1]) }
          it { should eq [TimeRange.new(min: range1.min, max: range2.max)] }
        end
        context 'that are disjoint' do
          let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
          let(:range2) { range1.shift_by(3.hours) }
          subject { TimeRange.union([range2, range1]) }
          it { should eq [range1, range2] }
        end
        context 'that intersect at their boundaries' do
          let(:range1) { TimeRange.new(min: time, duration: + 2.hour) }
          let(:range2) { range1.shift_by(range1.duration) }
          subject { TimeRange.union([range2, range1]) }
          it { should eq [TimeRange.new(min: range1.min, max: range2.max)] }
        end
      end
    end
  end

  describe '.intersection' do
    it 'returns the intersection of all time ranges' do
      range1 = TimeRange.new(min: Time.zone.local(2012), duration: 3.days)
      range2 = range1.shift_by(-1.day)
      range3 = range1.shift_by(-2.days)
      expect(TimeRange.intersection([range1, range2, range3]))
        .to eq TimeRange.new(min: Time.zone.local(2012), duration: 1.day)
    end
    it 'returns nil if the intersection is empty' do
      range1 = TimeRange.new(min: Time.zone.local(2012), duration: 1.days)
      range2 = range1.shift_by(-2.day)
      range3 = range1.shift_by(-4.days)
      expect(TimeRange.intersection([range1, range2, range3])).to be_nil
    end
  end

  describe '#overlaps?' do
    let(:range) { TimeRange.new(min: time, duration: 3.hours) }
    context 'when self is equal to other' do
      let(:other) { range.clone }
      subject { range.overlaps?(other) }
      it { should be_true }
    end
    context 'when self covers other' do
      let(:other) do
        TimeRange.new(min: range.min + 1.hour, max: range.max - 1.hour)
      end
      subject { range.overlaps?(other) }
      it { should be_true }
    end
    context 'when other covers self' do
      let(:other) do
        TimeRange.new(min: range.min - 1.hour, max: range.max + 1.hour)
      end
      subject { range.overlaps?(other) }
      it { should be_true }
    end
    context 'when self begins earlier than other' do
      context 'and they are disjoint' do
        let(:other) { range.shift_by(-range.duration - 1.hour) }
        subject { range.overlaps?(other) }
        it { should be_false }
      end
      context 'and they are overlapping' do
        let(:other) { range.shift_by(-1.hours) }
        subject { range.overlaps?(other) }
        it { should be_true }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { range.shift_by(-range.duration) }
        subject { range.overlaps?(other) }
        it { should be_false }
      end
    end
    context 'when other begins earlier than self' do
      context 'and they are disjoint' do
        let(:other) { range.shift_by(range.duration + 1.hour) }
        subject { range.overlaps?(other) }
        it { should be_false }
      end
      context 'and they are overlapping' do
        let(:other) { range.shift_by(1.hours) }
        subject { range.overlaps?(other) }
        it { should be_true }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { range.shift_by(range.duration) }
        subject { range.overlaps?(other) }
        it { should be_false }
      end
    end
  end

  describe '#&' do
    let(:range) { TimeRange.new(min: time, duration: 3.hours) }
    context 'when self is equal to other' do
      let(:other) { range.clone }
      subject { range & other }
      it { should eq range }
    end
    context 'when self covers other' do
      let(:other) do
        TimeRange.new(min: range.min + 1.hour, max: range.max - 1.hour)
      end
      subject { range & other }
      it { should eq other }
    end
    context 'when other covers self' do
      let(:other) do
        TimeRange.new(min: range.min - 1.hour, max: range.max + 1.hour)
      end
      subject { range & other }
      it { should eq range }
    end
    context 'when self begins earlier than other' do
      context 'and they are disjoint' do
        let(:other) { range.shift_by(range.duration + 1.hour) }
        subject { range & other }
        it { should be_nil }
      end
      context 'and they are overlapping' do
        let(:other) { range.shift_by(1.hour) }
        subject { range & other }
        it { should eq TimeRange.new(min: other.min, max: range.max) }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { range.shift_by(range.duration) }
        subject { range & other }
        it { should eq TimeRange.new(min: range.max, max: range.max) }
      end
    end
    context 'when other begins earlier than self' do
      context 'and they are disjoint' do
        let(:other) { range.shift_by(-range.duration - 1.hour) }
        subject { range & other }
        it { should be_nil }
      end
      context 'and they are overlapping' do
        let(:other) { range.shift_by(-1.hour) }
        subject { range & other }
        it { should eq TimeRange.new(min: range.min, max: other.max) }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { range.shift_by(-range.duration) }
        subject { range & other }
        it { should eq TimeRange.new(min: range.min, max: range.min) }
      end
    end
  end

  describe '#split_by_interval' do
    context 'when time range duration is divisible by interval' do
      let(:time) { Time.new(2012, 1, 1) }
      let(:interval) { 1.day }
      let(:time_range) do
        TimeRange.new(min: time, duration: 7.days)
      end
      subject do
        time_range.split_by_interval(interval)
      end

      describe '#size' do
        subject { super().size }
        it { should eq 7 }
      end
      (0..6).each do |day|
        it "should have the right borders on day #{day}" do
          expected = TimeRange.new(min: time, duration: interval)
          expect(subject[day]).to eq expected.shift_by(day.days)
        end
      end
    end

    context 'when time range duration is not divisible by interval' do
      let(:time) { Time.new(2012, 1, 1) }
      let(:interval) { 1.day }
      let(:time_range) do
        TimeRange.new(min: time, duration: 7.days + 12.hours)
      end
      subject do
        time_range.split_by_interval(interval)
      end

      describe '#size' do
        subject { super().size }
        it { should eq 8 }
      end
      (0..6).each do |day|
        it "should have the right borders on day #{day}" do
          expected = TimeRange.new(min: time, duration: interval)
          expect(subject[day]).to eq expected.shift_by(day.days)
        end
      end
      it 'should have a smaller range at the end' do
        expected = TimeRange.new(min: time + 7.days, duration: 12.hours)
        expect(subject[7]).to eq expected
      end
    end
  end

  describe '#shift_by' do
    let(:min) { time }
    let(:max) { time + 2.days }
    let(:range) { TimeRange.new(min: min, max: max) }
    context 'when shifting into the future' do
      subject { range.shift_by(1.day) }

      describe '#min' do
        subject { super().min }
        it { should eq min + 1.day }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max + 1.day }
      end
      it { should_not equal range }
    end
    context 'when shifting into the past' do
      subject { range.shift_by(-1.day) }

      describe '#min' do
        subject { super().min }
        it { should eq min - 1.day }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max - 1.day }
      end
      it { should_not equal range }
    end
    context 'when shifting by 0' do
      subject { range.shift_by(0) }

      describe '#min' do
        subject { super().min }
        it { should eq min }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max }
      end
      it { should_not equal range }
    end
    context 'when shifting back and forth' do
      subject { range.shift_by(-1.day).shift_by(1.day) }

      describe '#min' do
        subject { super().min }
        it { should eq min }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max }
      end
      it { should_not equal range }
    end
  end

  describe '#shift_to' do

    let(:duration) { 1.day }
    let(:min)      { Time.zone.local(2012, 1, 2) }
    let(:max)      { min + duration }
    let(:range)    { TimeRange.new(min: min, max: max) }

    context 'when shifting to a future time' do
      let(:destination) { min + duration }
      subject   { range.shift_to(destination) }
      it { should_not equal range }

      describe '#min' do
        subject { super().min }
        it { should eq destination }
      end

      describe '#max' do
        subject { super().max }
        it { should eq destination + duration }
      end
    end

    context 'when shifting to a past time' do
      let(:destination) { min - duration }
      subject   { range.shift_to(destination) }
      it { should_not equal range }

      describe '#min' do
        subject { super().min }
        it { should eq destination }
      end

      describe '#max' do
        subject { super().max }
        it { should eq destination + duration }
      end
    end

    context 'when shifting to same time' do
      let(:destination) { min }
      subject   { range.shift_to(destination) }
      it { should_not equal range }

      describe '#min' do
        subject { super().min }
        it { should eq destination }
      end

      describe '#max' do
        subject { super().max }
        it { should eq destination + duration }
      end
    end
  end

  describe '#without' do
    context 'when providing a single range' do
      let(:range) { TimeRange.new(min: time, duration: 1.hour) }

      context 'and other is left of self' do
        context 'and they have a common border' do
          let(:other) { range.shift_by(-range.duration) }
          subject { range.without(other) }
          it { should eq [range] }
        end
        context 'and they do not have a common border' do
          let(:other) { range.shift_by(-2 * range.duration) }
          subject { range.without(other) }
          it { should eq [range] }
        end
        context 'and they overlap' do
          let(:other) { range.shift_by(-0.5 * range.duration) }
          subject { range.without(other) }
          it { should eq [TimeRange.new(min: other.max, max: range.max)] }
        end
      end

      context 'and other is right of self' do
        context 'and they have a common border' do
          let(:other) { range.shift_by(range.duration) }
          subject { range.without(other) }
          it { should eq [range] }
        end
        context 'and they do not have a common border' do
          let(:other) { range.shift_by(2 * range.duration) }
          subject { range.without(other) }
          it { should eq [range] }
        end
        context 'and they overlap' do
          let(:other) { range.shift_by(0.5 * range.duration) }
          subject { range.without(other) }
          it { should eq [TimeRange.new(min: range.min, max: other.min)] }
        end
      end

      context 'and other is contained within self' do
        context 'and other is equal to self' do
          subject { range.without(range) }
          it { should eq [] }
        end
        context 'and only left boundaries are equal' do
          let(:other) do
            TimeRange.new(min: time, duration: range.duration / 2)
          end
          subject { range.without(other) }
          it { should eq [TimeRange.new(min: other.max, max: range.max)] }
        end
        context 'and only right boundaries are equal' do
          let(:other) do
            TimeRange.new(min: time + range.duration / 2, max: range.max)
          end
          subject { range.without(other) }
          it { should eq [TimeRange.new(min: range.min, max: other.min)] }
        end
        context 'and they have no boundary in common' do
          let(:other) do
            TimeRange.new(min: time + range.duration / 3,
                          duration: range.duration / 3)
          end
          subject { range.without(other) }
          it do
            should eq [
              TimeRange.new(min: range.min, max: other.min),
              TimeRange.new(min: other.max, max: range.max)
            ]
          end
        end
      end
    end

    context 'when providing an array' do
      let(:range) { TimeRange.new(min: time, duration: 10.hours) }
      context 'and providing one range' do
        context 'and its equal to self' do
          let(:arg) { [range] }
          subject { range.without(*arg) }
          it { should eq [] }
        end
      end
      context 'and providing several ranges' do
        context 'and they do not intersect' do
          context 'and do not touch the boundaries' do
            let(:arg) do
              shift = range.duration + 1.hour
              [
                TimeRange.new(min: time - 2.hours, duration: 1.hour),
                TimeRange.new(min: time + shift, duration: 1.hour)
              ]
            end
            subject { range.without(*arg) }
            it { should eq [range] }
          end
          context 'and they touch boundaries' do
            let(:arg) do
              [
                TimeRange.new(min: time - 1.hour, duration: 1.hour),
                TimeRange.new(min: time + range.duration, duration: 1.hour)
              ]
            end
            subject { range.without(*arg) }
            it { should eq [range] }
          end
        end
        context 'and they intersect' do
          context 'and the argument ranges overlaps themself' do
            let(:arg) do
              [
                TimeRange.new(min: time + 1.hour, duration: 2.hours),
                TimeRange.new(min: time + 2.hours, duration: 2.hours)
              ]
            end
            let(:expected) do
              [
                TimeRange.new(min: range.min, duration: 1.hour),
                TimeRange.new(min: time + 4.hours, max: range.max)
              ]
            end
            subject { range.without(*arg) }
            it { should eq expected }
          end
          context 'and they cover self' do
            let(:arg) do
              duration = 0.5 * range.duration
              [
                TimeRange.new(min: time, duration: duration),
                TimeRange.new(min: time + duration, duration: duration)
              ]
            end
            subject { range.without(*arg) }
            it { should eq [] }
          end
          context 'and they overlap at the boundaries' do
            let(:arg) do
              shift = range.duration - 1.hour
              [
                TimeRange.new(min: time - 1.hour, duration: 2.hour),
                TimeRange.new(min: time + shift, duration: 2.hour)
              ]
            end
            let(:expected) do
              [
                TimeRange.new(min: range.min + 1.hour,
                              max: range.max - 1.hour)
              ]
            end
            subject { range.without(*arg) }
            it { should eq expected }
          end
          context 'and we have three ranges in args overlaped by self' do
            context 'which are sorted' do
              let(:arg) do
                [
                  TimeRange.new(min: time + 1.hour, duration: 2.hour),
                  TimeRange.new(min: time + 4.hours, duration: 2.hour),
                  TimeRange.new(min: time + 7.hours, duration: 2.hour)
                ]
              end
              let(:expected) do
                [
                  TimeRange.new(min: time, max: time + 1.hour),
                  TimeRange.new(min: time + 3.hours, max: time + 4.hour),
                  TimeRange.new(min: time + 6.hours, max: time + 7.hours),
                  TimeRange.new(min: time + 9.hours, max: time + 10.hours)
                ]
              end
              subject { range.without(*arg) }
              it { should eq expected }
            end
            context 'and they are unsorted' do
              let(:arg) do
                [
                  TimeRange.new(min: time + 4.hours, duration: 2.hour),
                  TimeRange.new(min: time + 1.hour, duration: 2.hour),
                  TimeRange.new(min: time + 7.hours, duration: 2.hour)
                ]
              end
              let(:expected) do
                [
                  TimeRange.new(min: time, max: time + 1.hour),
                  TimeRange.new(min: time + 3.hours, max: time + 4.hour),
                  TimeRange.new(min: time + 6.hours, max: time + 7.hours),
                  TimeRange.new(min: time + 9.hours, max: time + 10.hours)
                ]
              end
              subject { range.without(*arg) }
              it { should eq expected }
            end
          end
        end
      end
    end
  end

  describe '.covering_time_range_for' do

    context 'for an empty array' do
      subject { TimeRange.covering_time_range_for([]) }
      it { should be_nil }
    end

    context 'for a single time range' do
      let(:range) { TimeRange.new(min: time, duration: 1.hour) }
      subject { TimeRange.covering_time_range_for([range]) }
      it { should eq range }
    end

    context 'for multiple time ranges' do
      let(:range1) { TimeRange.new(min: time, duration: 2.hours) }
      let(:range2) { range1.shift_by(-1.hour) }
      let(:range3) { range1.shift_by(3.hours) }
      subject do
        TimeRange.covering_time_range_for([range1, range2, range3])
      end

      describe '#min' do
        subject { super().min }
        it { should eq range2.min }
      end

      describe '#max' do
        subject { super().max }
        it { should eq range3.max }
      end
    end
  end

  describe '.each_overlap' do

    # Visualization of example input:
    #
    # array1:       |---|-------|   |-------|-----------|
    # array2:               |-----------|   |---|   |---|   |---|
    #
    #               0   1   2   3   4   5   6   7   8   9  10  11

    let(:array1) do
      [
        TimeRange.new(min: time, max: time + 1.hour),
        TimeRange.new(min: time + 1.hour, max: time + 3.hours),
        TimeRange.new(min: time + 4.hours, max: time + 6.hours),
        TimeRange.new(min: time + 6.hours, max: time + 9.hours)
      ]
    end

    let(:array2) do
      [
        TimeRange.new(min: time + 2.hours, max: time + 5.hour),
        TimeRange.new(min: time + 6.hour, max: time + 7.hours),
        TimeRange.new(min: time + 8.hours, max: time + 9.hours),
        TimeRange.new(min: time + 10.hours, max: time + 11.hours)
      ]
    end

    it 'yields the block for each overlap' do
      overlaps = []
      TimeRange.each_overlap(array1, array2) { |a, b| overlaps << [a, b] }
      expect(overlaps).to eq [
        [array1[1], array2[0]],
        [array1[2], array2[0]],
        [array1[3], array2[1]],
        [array1[3], array2[2]]
      ]
    end

    it 'still works when switching arguments' do
      overlaps = []
      TimeRange.each_overlap(array2, array1) { |a, b| overlaps << [a, b] }
      expect(overlaps).to eq [
        [array2[0], array1[1]],
        [array2[0], array1[2]],
        [array2[1], array1[3]],
        [array2[2], array1[3]]
      ]
    end

    it 'works if first array is empty' do
      overlaps = []
      TimeRange.each_overlap([], array2) { |a, b| overlaps << [a, b] }
      expect(overlaps).to be_empty
    end

    it 'works if second array is empty' do
      overlaps = []
      TimeRange.each_overlap(array1, []) { |a, b| overlaps << [a, b] }
      expect(overlaps).to be_empty
    end
  end

  describe '#inspect' do
    it 'works for a TimeRange with same min and max' do
      time = Time.now
      expected = "#{time}..#{time}"
      tr = TimeRange.new(min: time, max: time)
      actual = tr.inspect
      expect(actual).to eq expected
    end

    it 'works for a TimeRange created with min and max' do
      min = Time.now
      max = min + 10.minutes
      expected = "#{min}..#{max}"
      tr = TimeRange.new(min: min, max: max)
      actual = tr.inspect
      expect(actual).to eq expected
    end

    it 'works for a TimeRange created with min and duration' do
      min = Time.now
      max = min + 10.minutes
      expected = "#{min}..#{max}"
      tr = TimeRange.new(min: min, duration: 10.minutes)
      actual = tr.inspect
      expect(actual).to eq expected
    end
  end
end
