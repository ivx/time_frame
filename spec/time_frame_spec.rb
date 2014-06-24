# Encoding: utf-8
require 'spec_helper'

describe TimeFrame do
  let(:time) { Time.zone.local(2012) }
  let(:duration) { 2.hours }

  before do
    # Avoid i18n deprecation warning
    I18n.enforce_available_locales = true
  end

  describe '#initialize' do
    context 'when given two times' do
      context 'and min is smaller than max' do
        subject { TimeFrame.new(min: time, max: time + duration) }

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
            TimeFrame.new(min: time, max: time - 1.day)
          end.to raise_error(ArgumentError)
        end
      end
      context 'which are equal' do
        subject { TimeFrame.new(min: time, max: time) }

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
        subject { TimeFrame.new(min: time, duration: 1.hour) }

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
        let(:invalid_t_r) { TimeFrame.new(min: time, duration: - 1.hour) }
        specify { expect { invalid_t_r }.to raise_error }
      end
      context 'and duration is 0' do
        subject { TimeFrame.new(min: time, duration: 0.hour) }

        describe '#min' do
          subject { super().min }
          it { should eq time }
        end

        describe '#max' do
          subject { super().max }
          it { should eq time }
        end
      end
      context 'and time frame covers a DST shift' do
        let(:time) do
          Time.use_zone('Europe/Berlin') { Time.zone.local(2013, 10, 27) }
        end
        subject { TimeFrame.new(min: time, duration: 1.day) }

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
      subject { TimeFrame.new(min: time, duration: 2.hours).duration }
      it { should eq 2.hours }
    end
    context 'when borders are equal' do
      subject { TimeFrame.new(min: time, max: time).duration }
      it { should eq 0 }
    end
    context 'when time frame containts a DST shift' do
      it 'should gain 1 hour on summer -> winter shifts' do
        Time.use_zone('Europe/Berlin') do
          time_frame = TimeFrame.new(min: Time.zone.local(2013, 10, 27),
                                     max: Time.zone.local(2013, 10, 28))
          expect(time_frame.duration).to eq 25.hours
        end
      end
      it 'should lose 1 hour on winter -> summer shifts' do
        Time.use_zone('Europe/Berlin') do
          time_frame = TimeFrame.new(min: Time.zone.local(2013, 3, 31),
                                     max: Time.zone.local(2013, 4, 1))
          expect(time_frame.duration).to eq 23.hours
        end
      end
    end
  end

  describe '#==' do
    let(:frame) { TimeFrame.new(min: time, duration: 2.hours) }
    context 'when borders are equal' do
      let(:other) { TimeFrame.new(min: time, duration: 2.hours) }
      subject { frame == other }
      it { should be_true }
    end
    context 'when min value is different' do
      let(:other) do
        TimeFrame.new(min: time - 1.hour, max: time + 2.hours)
      end
      subject { frame == other }
      it { should be_false }
    end
    context 'when max value is different' do
      let(:other) { TimeFrame.new(min: time, duration: 3.hours) }
      subject { frame == other }
      it { should be_false }
    end
  end

  describe '#cover?' do
    let(:frame) { TimeFrame.new(min: time, duration: 4.hours) }
    context 'when argument is a Time instance' do
      context 'and its covered' do
        context 'and equal to min' do
          subject { frame.cover?(frame.min) }
          it { should be_true }
        end
        context 'and equal to max' do
          subject { frame.cover?(frame.max) }
          it { should be_true }
        end
        context 'and is an inner value' do
          subject { frame.cover?(frame.min + 1.hour) }
          it { should be_true }
        end
      end
      context 'and its not covered' do
        context 'and smaller than min' do
          subject { frame.cover?(frame.min - 1.hour) }
          it { should be_false }
        end
        context 'and greater than max' do
          subject { frame.cover?(frame.max + 5.hours) }
          it { should be_false }
        end
      end
    end
    context 'when argument is a TimeFrame' do
      context 'and its covered' do
        context 'and they have the same min value' do
          let(:other) { TimeFrame.new(min: frame.min, duration: 2.hours) }
          subject { frame.cover?(other) }
          it { should be_true }
        end
        context 'and they have the same max value' do
          let(:other) do
            TimeFrame.new(min: frame.min + 1.hour, max: frame.max)
          end
          subject { frame.cover?(other) }
          it { should be_true }
        end
        context 'and it is within the interior of self' do
          let(:other) do
            TimeFrame.new(min: frame.min + 1.hour, max: frame.max - 1.hour)
          end
          subject { frame.cover?(other) }
          it { should be_true }
        end
        context 'and are equal' do
          let(:other) { frame.clone }
          subject { frame.cover?(other) }
          it { should be_true }
        end
      end
      context 'and it is not covered' do
        context 'and other is left of self' do
          let(:other) { frame.shift_by(-5.hours) }
          subject { frame.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps left hand side' do
          let(:other) { frame.shift_by(-1.hour) }
          subject { frame.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps left hand side at the border only' do
          let(:other) { frame.shift_by(-frame.duration) }
          subject { frame.cover?(other) }
          it { should be_false }
        end
        context 'and other is right of self' do
          let(:other) { frame.shift_by(5.hours) }
          subject { frame.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps right hand side' do
          let(:other) { frame.shift_by(1.hours) }
          subject { frame.cover?(other) }
          it { should be_false }
        end
        context 'and other overlaps right hand side at the border only' do
          let(:other) { frame.shift_by(frame.duration) }
          subject { frame.cover?(other) }
          it { should be_false }
        end
      end
    end
  end

  describe '#deviation_of' do
    let(:time_frame) do
      TimeFrame.new(min: Time.zone.local(2012), duration: 2.days)
    end
    context 'when providing a time object' do
      describe 'when self covers time' do
        context 'and time equals min' do
          let(:time) { time_frame.min }
          subject { time_frame.deviation_of(time) }
          it { should eq 0.minutes }
        end
        context 'and time equals max' do
          let(:time) { time_frame.max }
          subject { time_frame.deviation_of(time) }
          it { should eq 0.minutes }
        end
        context 'and time is an interior point of self' do
          let(:time) { time_frame.min + (time_frame.duration / 2.0) }
          subject { time_frame.deviation_of(time) }
          it { should eq 0.minutes }
        end
      end
      context 'when self do not cover time' do
        context 'and time is smaller than the left bound' do
          let(:time) { time_frame.min - 42.hours - 42.minutes }
          subject { time_frame.deviation_of(time) }
          it { should eq(-42.hours - 42.minutes) }
        end
        context 'and time is greater than the right bound' do
          let(:time) { time_frame.max + 42.hours + 42.minutes }
          subject { time_frame.deviation_of(time) }
          it { should eq 42.hours + 42.minutes }
        end
      end
    end
    context 'when providing a time_frame' do
      describe 'when self overlaps other' do
        context 'and its partly' do
          let(:other) { time_frame.shift_by(time_frame.duration / 2) }
          subject { time_frame.deviation_of(other) }
          it { should eq 0.minutes }
        end
        context 'and time equals max' do
          let(:other) { time_frame }
          subject { time_frame.deviation_of(other) }
          it { should eq 0.minutes }
        end
        context 'and other lies in the interior of self' do
          let(:other) do
            TimeFrame.new(min: time_frame.min + 1.hour, duration: 1.hour)
          end
          subject { time_frame.deviation_of(other) }
          it { should eq 0.minutes }
        end
      end
      context 'when self do not cover time' do
        context 'and time is smaller than the left bound' do
          let(:other) { time_frame.shift_by(-2.days - 42.seconds) }
          subject { time_frame.deviation_of(other) }
          it { should eq(-42.seconds) }
        end
        context 'and time is greater than the right bound' do
          let(:other) { time_frame.shift_by(2.days + 42.seconds) }
          subject { time_frame.deviation_of(other) }
          it { should eq 42.seconds }
        end
      end
    end
  end

  describe '#empty?' do
    context 'when min equals max' do
      subject { TimeFrame.new(min: time, max: time) }
      it { should be_empty }
    end

    context 'when max is greater than min' do
      subject { TimeFrame.new(min: time, duration: 1.day) }
      it { should_not be_empty }
    end
  end

  describe '.union' do

    context 'when given an empty array' do
      subject { TimeFrame.union([]) }
      it { should eq [] }
    end

    context 'when given a single time frame' do
      let(:frame) { TimeFrame.new(min: time, duration: 1.hour) }
      subject { TimeFrame.union([frame]) }
      it { should eq [frame] }
    end

    context 'when getting single element it returns a dup' do
      let(:frames) { [TimeFrame.new(min: time, duration: 1.hour)] }
      subject { TimeFrame.union(frames) }
      it { should_not equal frames }
    end

    context 'when given time frames' do
      context 'in order' do
        context 'and no sorted flag is provided' do
          context 'that are overlapping' do
            let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
            let(:frame2) { frame1.shift_by(1.hour) }
            let(:expected) do
              [TimeFrame.new(min: frame1.min, max: frame2.max)]
            end
            subject { TimeFrame.union([frame1, frame2]) }
            it { should eq expected }
          end
          context 'that are disjoint' do
            let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
            let(:frame2) { frame1.shift_by(3.hours) }
            subject { TimeFrame.union([frame1, frame2]) }
            it { should eq [frame1, frame2] }
          end
          context 'that intersect at their boundaries' do
            let(:frame1) { TimeFrame.new(min: time, duration: + 2.hour) }
            let(:frame2) { frame1.shift_by(frame1.duration) }
            let(:expected) do
              [TimeFrame.new(min: frame1.min, max: frame2.max)]
            end
            subject { TimeFrame.union([frame1, frame2]) }
            it { should eq expected }
          end
        end
        context 'and the sorted flag is provided' do
          context 'that are overlapping' do
            let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
            let(:frame2) { frame1.shift_by(1.hour) }
            let(:expected) do
              [TimeFrame.new(min: frame1.min, max: frame2.max)]
            end
            subject { TimeFrame.union([frame1, frame2], sorted: true) }
            it { should eq expected }
          end
          context 'that are disjoint' do
            let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
            let(:frame2) { frame1.shift_by(3.hours) }
            subject { TimeFrame.union([frame1, frame2], sorted: true) }
            it { should eq [frame1, frame2] }
          end
          context 'that intersect at their boundaries' do
            let(:frame1) { TimeFrame.new(min: time, duration: + 2.hour) }
            let(:frame2) { frame1.shift_by(frame1.duration) }
            let(:expected) do
              [TimeFrame.new(min: frame1.min, max: frame2.max)]
            end
            subject { TimeFrame.union([frame1, frame2], sorted: true) }
            it { should eq expected }
          end
        end
      end
      context 'not in order' do
        context 'that are overlapping' do
          let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
          let(:frame2) { frame1.shift_by(1.hour) }
          subject { TimeFrame.union([frame2, frame1]) }
          it { should eq [TimeFrame.new(min: frame1.min, max: frame2.max)] }
        end
        context 'that are disjoint' do
          let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
          let(:frame2) { frame1.shift_by(3.hours) }
          subject { TimeFrame.union([frame2, frame1]) }
          it { should eq [frame1, frame2] }
        end
        context 'that intersect at their boundaries' do
          let(:frame1) { TimeFrame.new(min: time, duration: + 2.hour) }
          let(:frame2) { frame1.shift_by(frame1.duration) }
          subject { TimeFrame.union([frame2, frame1]) }
          it { should eq [TimeFrame.new(min: frame1.min, max: frame2.max)] }
        end
      end
    end
  end

  describe '.intersection' do
    it 'returns the intersection of all time frames' do
      frame1 = TimeFrame.new(min: Time.zone.local(2012), duration: 3.days)
      frame2 = frame1.shift_by(-1.day)
      frame3 = frame1.shift_by(-2.days)
      expect(TimeFrame.intersection([frame1, frame2, frame3]))
        .to eq TimeFrame.new(min: Time.zone.local(2012), duration: 1.day)
    end
    it 'returns nil if the intersection is empty' do
      frame1 = TimeFrame.new(min: Time.zone.local(2012), duration: 1.days)
      frame2 = frame1.shift_by(-2.day)
      frame3 = frame1.shift_by(-4.days)
      expect(TimeFrame.intersection([frame1, frame2, frame3])).to be_nil
    end
  end

  describe '#overlaps?' do
    let(:frame) { TimeFrame.new(min: time, duration: 3.hours) }
    context 'when self is equal to other' do
      let(:other) { frame.clone }
      subject { frame.overlaps?(other) }
      it { should be_true }
    end
    context 'when self covers other' do
      let(:other) do
        TimeFrame.new(min: frame.min + 1.hour, max: frame.max - 1.hour)
      end
      subject { frame.overlaps?(other) }
      it { should be_true }
    end
    context 'when other covers self' do
      let(:other) do
        TimeFrame.new(min: frame.min - 1.hour, max: frame.max + 1.hour)
      end
      subject { frame.overlaps?(other) }
      it { should be_true }
    end
    context 'when self begins earlier than other' do
      context 'and they are disjoint' do
        let(:other) { frame.shift_by(-frame.duration - 1.hour) }
        subject { frame.overlaps?(other) }
        it { should be_false }
      end
      context 'and they are overlapping' do
        let(:other) { frame.shift_by(-1.hours) }
        subject { frame.overlaps?(other) }
        it { should be_true }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { frame.shift_by(-frame.duration) }
        subject { frame.overlaps?(other) }
        it { should be_false }
      end
    end
    context 'when other begins earlier than self' do
      context 'and they are disjoint' do
        let(:other) { frame.shift_by(frame.duration + 1.hour) }
        subject { frame.overlaps?(other) }
        it { should be_false }
      end
      context 'and they are overlapping' do
        let(:other) { frame.shift_by(1.hours) }
        subject { frame.overlaps?(other) }
        it { should be_true }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { frame.shift_by(frame.duration) }
        subject { frame.overlaps?(other) }
        it { should be_false }
      end
    end
  end

  describe '#&' do
    let(:frame) { TimeFrame.new(min: time, duration: 3.hours) }
    context 'when self is equal to other' do
      let(:other) { frame.clone }
      subject { frame & other }
      it { should eq frame }
    end
    context 'when self covers other' do
      let(:other) do
        TimeFrame.new(min: frame.min + 1.hour, max: frame.max - 1.hour)
      end
      subject { frame & other }
      it { should eq other }
    end
    context 'when other covers self' do
      let(:other) do
        TimeFrame.new(min: frame.min - 1.hour, max: frame.max + 1.hour)
      end
      subject { frame & other }
      it { should eq frame }
    end
    context 'when self begins earlier than other' do
      context 'and they are disjoint' do
        let(:other) { frame.shift_by(frame.duration + 1.hour) }
        subject { frame & other }
        it { should be_nil }
      end
      context 'and they are overlapping' do
        let(:other) { frame.shift_by(1.hour) }
        subject { frame & other }
        it { should eq TimeFrame.new(min: other.min, max: frame.max) }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { frame.shift_by(frame.duration) }
        subject { frame & other }
        it { should eq TimeFrame.new(min: frame.max, max: frame.max) }
      end
    end
    context 'when other begins earlier than self' do
      context 'and they are disjoint' do
        let(:other) { frame.shift_by(-frame.duration - 1.hour) }
        subject { frame & other }
        it { should be_nil }
      end
      context 'and they are overlapping' do
        let(:other) { frame.shift_by(-1.hour) }
        subject { frame & other }
        it { should eq TimeFrame.new(min: frame.min, max: other.max) }
      end
      context 'and they intersect at their boundaries' do
        let(:other) { frame.shift_by(-frame.duration) }
        subject { frame & other }
        it { should eq TimeFrame.new(min: frame.min, max: frame.min) }
      end
    end
  end

  describe '#split_by_interval' do
    context 'when time frame duration is divisible by interval' do
      let(:time) { Time.new(2012, 1, 1) }
      let(:interval) { 1.day }
      let(:time_frame) do
        TimeFrame.new(min: time, duration: 7.days)
      end
      subject do
        time_frame.split_by_interval(interval)
      end

      describe '#size' do
        subject { super().size }
        it { should eq 7 }
      end
      (0..6).each do |day|
        it "should have the right borders on day #{day}" do
          expected = TimeFrame.new(min: time, duration: interval)
          expect(subject[day]).to eq expected.shift_by(day.days)
        end
      end
    end

    context 'when time frame duration is not divisible by interval' do
      let(:time) { Time.new(2012, 1, 1) }
      let(:interval) { 1.day }
      let(:time_frame) do
        TimeFrame.new(min: time, duration: 7.days + 12.hours)
      end
      subject do
        time_frame.split_by_interval(interval)
      end

      describe '#size' do
        subject { super().size }
        it { should eq 8 }
      end
      (0..6).each do |day|
        it "should have the right borders on day #{day}" do
          expected = TimeFrame.new(min: time, duration: interval)
          expect(subject[day]).to eq expected.shift_by(day.days)
        end
      end
      it 'should have a smaller frame at the end' do
        expected = TimeFrame.new(min: time + 7.days, duration: 12.hours)
        expect(subject[7]).to eq expected
      end
    end
  end

  describe '#shift_by' do
    let(:min) { time }
    let(:max) { time + 2.days }
    let(:frame) { TimeFrame.new(min: min, max: max) }
    context 'when shifting into the future' do
      subject { frame.shift_by(1.day) }

      describe '#min' do
        subject { super().min }
        it { should eq min + 1.day }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max + 1.day }
      end
      it { should_not equal frame }
    end
    context 'when shifting into the past' do
      subject { frame.shift_by(-1.day) }

      describe '#min' do
        subject { super().min }
        it { should eq min - 1.day }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max - 1.day }
      end
      it { should_not equal frame }
    end
    context 'when shifting by 0' do
      subject { frame.shift_by(0) }

      describe '#min' do
        subject { super().min }
        it { should eq min }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max }
      end
      it { should_not equal frame }
    end
    context 'when shifting back and forth' do
      subject { frame.shift_by(-1.day).shift_by(1.day) }

      describe '#min' do
        subject { super().min }
        it { should eq min }
      end

      describe '#max' do
        subject { super().max }
        it { should eq max }
      end
      it { should_not equal frame }
    end
  end

  describe '#shift_to' do

    let(:duration) { 1.day }
    let(:min)      { Time.zone.local(2012, 1, 2) }
    let(:max)      { min + duration }
    let(:frame)    { TimeFrame.new(min: min, max: max) }

    context 'when shifting to a future time' do
      let(:destination) { min + duration }
      subject   { frame.shift_to(destination) }
      it { should_not equal frame }

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
      subject   { frame.shift_to(destination) }
      it { should_not equal frame }

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
      subject   { frame.shift_to(destination) }
      it { should_not equal frame }

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
    context 'when providing a single frame' do
      let(:frame) { TimeFrame.new(min: time, duration: 1.hour) }

      context 'and other is left of self' do
        context 'and they have a common border' do
          let(:other) { frame.shift_by(-frame.duration) }
          subject { frame.without(other) }
          it { should eq [frame] }
        end
        context 'and they do not have a common border' do
          let(:other) { frame.shift_by(-2 * frame.duration) }
          subject { frame.without(other) }
          it { should eq [frame] }
        end
        context 'and they overlap' do
          let(:other) { frame.shift_by(-0.5 * frame.duration) }
          subject { frame.without(other) }
          it { should eq [TimeFrame.new(min: other.max, max: frame.max)] }
        end
      end

      context 'and other is right of self' do
        context 'and they have a common border' do
          let(:other) { frame.shift_by(frame.duration) }
          subject { frame.without(other) }
          it { should eq [frame] }
        end
        context 'and they do not have a common border' do
          let(:other) { frame.shift_by(2 * frame.duration) }
          subject { frame.without(other) }
          it { should eq [frame] }
        end
        context 'and they overlap' do
          let(:other) { frame.shift_by(0.5 * frame.duration) }
          subject { frame.without(other) }
          it { should eq [TimeFrame.new(min: frame.min, max: other.min)] }
        end
      end

      context 'and other is contained within self' do
        context 'and other is equal to self' do
          subject { frame.without(frame) }
          it { should eq [] }
        end
        context 'and only left boundaries are equal' do
          let(:other) do
            TimeFrame.new(min: time, duration: frame.duration / 2)
          end
          subject { frame.without(other) }
          it { should eq [TimeFrame.new(min: other.max, max: frame.max)] }
        end
        context 'and only right boundaries are equal' do
          let(:other) do
            TimeFrame.new(min: time + frame.duration / 2, max: frame.max)
          end
          subject { frame.without(other) }
          it { should eq [TimeFrame.new(min: frame.min, max: other.min)] }
        end
        context 'and they have no boundary in common' do
          let(:other) do
            TimeFrame.new(min: time + frame.duration / 3,
                          duration: frame.duration / 3)
          end
          subject { frame.without(other) }
          it do
            should eq [
              TimeFrame.new(min: frame.min, max: other.min),
              TimeFrame.new(min: other.max, max: frame.max)
            ]
          end
        end
      end
    end

    context 'when providing an array' do
      let(:frame) { TimeFrame.new(min: time, duration: 10.hours) }
      context 'and providing one frame' do
        context 'and its equal to self' do
          let(:arg) { [frame] }
          subject { frame.without(*arg) }
          it { should eq [] }
        end
      end
      context 'and providing several frames' do
        context 'and they do not intersect' do
          context 'and do not touch the boundaries' do
            let(:arg) do
              shift = frame.duration + 1.hour
              [
                TimeFrame.new(min: time - 2.hours, duration: 1.hour),
                TimeFrame.new(min: time + shift, duration: 1.hour)
              ]
            end
            subject { frame.without(*arg) }
            it { should eq [frame] }
          end
          context 'and they touch boundaries' do
            let(:arg) do
              [
                TimeFrame.new(min: time - 1.hour, duration: 1.hour),
                TimeFrame.new(min: time + frame.duration, duration: 1.hour)
              ]
            end
            subject { frame.without(*arg) }
            it { should eq [frame] }
          end
        end
        context 'and they intersect' do
          context 'and the argument frames overlaps themself' do
            let(:arg) do
              [
                TimeFrame.new(min: time + 1.hour, duration: 2.hours),
                TimeFrame.new(min: time + 2.hours, duration: 2.hours)
              ]
            end
            let(:expected) do
              [
                TimeFrame.new(min: frame.min, duration: 1.hour),
                TimeFrame.new(min: time + 4.hours, max: frame.max)
              ]
            end
            subject { frame.without(*arg) }
            it { should eq expected }
          end
          context 'and they cover self' do
            let(:arg) do
              duration = 0.5 * frame.duration
              [
                TimeFrame.new(min: time, duration: duration),
                TimeFrame.new(min: time + duration, duration: duration)
              ]
            end
            subject { frame.without(*arg) }
            it { should eq [] }
          end
          context 'and they overlap at the boundaries' do
            let(:arg) do
              shift = frame.duration - 1.hour
              [
                TimeFrame.new(min: time - 1.hour, duration: 2.hour),
                TimeFrame.new(min: time + shift, duration: 2.hour)
              ]
            end
            let(:expected) do
              [
                TimeFrame.new(min: frame.min + 1.hour,
                              max: frame.max - 1.hour)
              ]
            end
            subject { frame.without(*arg) }
            it { should eq expected }
          end
          context 'and we have three frames in args overlaped by self' do
            context 'which are sorted' do
              let(:arg) do
                [
                  TimeFrame.new(min: time + 1.hour, duration: 2.hour),
                  TimeFrame.new(min: time + 4.hours, duration: 2.hour),
                  TimeFrame.new(min: time + 7.hours, duration: 2.hour)
                ]
              end
              let(:expected) do
                [
                  TimeFrame.new(min: time, max: time + 1.hour),
                  TimeFrame.new(min: time + 3.hours, max: time + 4.hour),
                  TimeFrame.new(min: time + 6.hours, max: time + 7.hours),
                  TimeFrame.new(min: time + 9.hours, max: time + 10.hours)
                ]
              end
              subject { frame.without(*arg) }
              it { should eq expected }
            end
            context 'and they are unsorted' do
              let(:arg) do
                [
                  TimeFrame.new(min: time + 4.hours, duration: 2.hour),
                  TimeFrame.new(min: time + 1.hour, duration: 2.hour),
                  TimeFrame.new(min: time + 7.hours, duration: 2.hour)
                ]
              end
              let(:expected) do
                [
                  TimeFrame.new(min: time, max: time + 1.hour),
                  TimeFrame.new(min: time + 3.hours, max: time + 4.hour),
                  TimeFrame.new(min: time + 6.hours, max: time + 7.hours),
                  TimeFrame.new(min: time + 9.hours, max: time + 10.hours)
                ]
              end
              subject { frame.without(*arg) }
              it { should eq expected }
            end
          end
        end
      end
    end
  end

  describe '.covering_time_frame_for' do

    context 'for an empty array' do
      subject { TimeFrame.covering_time_frame_for([]) }
      it { should be_nil }
    end

    context 'for a single time frame' do
      let(:frame) { TimeFrame.new(min: time, duration: 1.hour) }
      subject { TimeFrame.covering_time_frame_for([frame]) }
      it { should eq frame }
    end

    context 'for multiple time frames' do
      let(:frame1) { TimeFrame.new(min: time, duration: 2.hours) }
      let(:frame2) { frame1.shift_by(-1.hour) }
      let(:frame3) { frame1.shift_by(3.hours) }
      subject do
        TimeFrame.covering_time_frame_for([frame1, frame2, frame3])
      end

      describe '#min' do
        subject { super().min }
        it { should eq frame2.min }
      end

      describe '#max' do
        subject { super().max }
        it { should eq frame3.max }
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
        TimeFrame.new(min: time, max: time + 1.hour),
        TimeFrame.new(min: time + 1.hour, max: time + 3.hours),
        TimeFrame.new(min: time + 4.hours, max: time + 6.hours),
        TimeFrame.new(min: time + 6.hours, max: time + 9.hours)
      ]
    end

    let(:array2) do
      [
        TimeFrame.new(min: time + 2.hours, max: time + 5.hour),
        TimeFrame.new(min: time + 6.hour, max: time + 7.hours),
        TimeFrame.new(min: time + 8.hours, max: time + 9.hours),
        TimeFrame.new(min: time + 10.hours, max: time + 11.hours)
      ]
    end

    it 'yields the block for each overlap' do
      overlaps = []
      TimeFrame.each_overlap(array1, array2) { |a, b| overlaps << [a, b] }
      expect(overlaps).to eq [
        [array1[1], array2[0]],
        [array1[2], array2[0]],
        [array1[3], array2[1]],
        [array1[3], array2[2]]
      ]
    end

    it 'still works when switching arguments' do
      overlaps = []
      TimeFrame.each_overlap(array2, array1) { |a, b| overlaps << [a, b] }
      expect(overlaps).to eq [
        [array2[0], array1[1]],
        [array2[0], array1[2]],
        [array2[1], array1[3]],
        [array2[2], array1[3]]
      ]
    end

    it 'works if first array is empty' do
      overlaps = []
      TimeFrame.each_overlap([], array2) { |a, b| overlaps << [a, b] }
      expect(overlaps).to be_empty
    end

    it 'works if second array is empty' do
      overlaps = []
      TimeFrame.each_overlap(array1, []) { |a, b| overlaps << [a, b] }
      expect(overlaps).to be_empty
    end
  end

  describe '#inspect' do
    it 'works for a TimeFrame with same min and max' do
      time = Time.now
      expected = "#{time}..#{time}"
      tr = TimeFrame.new(min: time, max: time)
      actual = tr.inspect
      expect(actual).to eq expected
    end

    it 'works for a TimeFrame created with min and max' do
      min = Time.now
      max = min + 10.minutes
      expected = "#{min}..#{max}"
      tr = TimeFrame.new(min: min, max: max)
      actual = tr.inspect
      expect(actual).to eq expected
    end

    it 'works for a TimeFrame created with min and duration' do
      min = Time.now
      max = min + 10.minutes
      expected = "#{min}..#{max}"
      tr = TimeFrame.new(min: min, duration: 10.minutes)
      actual = tr.inspect
      expect(actual).to eq expected
    end
  end
end
