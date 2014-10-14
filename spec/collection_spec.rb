require 'spec_helper'

describe TimeFrame::Collection do

  let(:time_frame) { TimeFrame.new(min: Time.utc(2014), duration: 20.days) }
  let(:time) { Time.utc(2014) }

  describe '#each' do
    it 'has map implemented' do
      time_frames = 20.times.map { |i| time_frame.shift_by((5 * i).days) }
      objects = time_frames.map { |tf| OpenStruct.new(interval: tf) }
      tree = TimeFrame::Collection.new(objects) { |o| o.interval }
      expect(tree.map { |item| item.interval }).to eq time_frames
    end
  end

  describe '#all_covering' do
    context 'when a pure time_frame tree is given' do
      it 'returns all covering time_frames' do
        time_frames = 20.times.map { |i| time_frame.shift_by((5 * i).days) }
        tree = TimeFrame::Collection.new(time_frames)

        result = tree.all_covering(time)
        expected_result = time_frames.select { |t| t.cover?(time) }
        expect(result).to eq expected_result

        result = tree.all_covering(time - 1.day)
        expect(result).to eq []

        result = tree.all_covering(time + 5.days)
        expected_result = time_frames.select { |t| t.cover?(time + 5.days) }
        expect(result).to eq expected_result

        result = tree.all_covering(time + 7.days)
        expected_result = time_frames.select { |t| t.cover?(time + 7.days) }
        expect(result).to eq expected_result

        result = tree.all_covering(time + 17.days)
        expected_result = time_frames.select { |t| t.cover?(time + 17.days) }
        expect(result).to eq expected_result

        result = tree.all_covering(time + 42.days)
        expected_result = time_frames.select { |t| t.cover?(time + 42.days) }
        expect(result).to eq expected_result

        result = tree.all_covering(time + 300.days)
        expect(result).to eq []
      end
    end

    context 'when objects containing time_frames are given' do
      it 'returns all covering time_frames' do
        objects = 20.times.map do |i|
          OpenStruct.new(time_frame: time_frame.shift_by((5 * i).days))
        end
        tree = TimeFrame::Collection.new(objects) { |item| item.time_frame }

        result = tree.all_covering(time - 1.day)
        expect(result).to eq []

        result = tree.all_covering(time + 5.days)
        expected_result = objects.select do |t|
          t.time_frame.cover?(time + 5.days)
        end
        expect(result).to eq expected_result

        result = tree.all_covering(time + 7.days)
        expected_result = objects.select do |t|
          t.time_frame.cover?(time + 7.days)
        end
        expect(result).to eq expected_result

        result = tree.all_covering(time + 17.days)
        expected_result = objects.select do |t|
          t.time_frame.cover?(time + 17.days)
        end
        expect(result).to eq expected_result

        result = tree.all_covering(time + 42.days)
        expected_result = objects.select do |t|
          t.time_frame.cover?(time + 42.days)
        end
        expect(result).to eq expected_result

        result = tree.all_covering(time + 300.days)
        expect(result).to eq []
      end
    end
  end

  describe '#all_intersecting' do
    context 'when a pure time_frame tree is given' do
      it 'returns all intersecting time_frames' do
        time_frames = 20.times.map { |i| time_frame.shift_by((5 * i).days) }
        tree = TimeFrame::Collection.new(time_frames)
        interval = TimeFrame.new(min: time, duration: 1.hour)

        result = tree.all_intersecting(interval.shift_by((-1).day))
        expect(result).to eq []

        result = tree.all_intersecting(interval)
        expected_result = time_frames.select do |t|
          !(t & (interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(5.days)
        result = tree.all_intersecting(this_interval)
        expected_result = time_frames.select do |t|
          !(t & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(7.days)
        result = tree.all_intersecting(this_interval)
        expected_result = time_frames.select do |t|
          !(t & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(17.days)
        result = tree.all_intersecting(this_interval)
        expected_result = time_frames.select do |t|
          !(t & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(42.days)
        result = tree.all_intersecting(this_interval)
        expected_result = time_frames.select do |t|
          !(t & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        result = tree.all_intersecting(interval.shift_by(300.days))
        expect(result).to eq []
      end
    end

    context 'when objects containing time_frames are given' do
      it 'returns all intersecting time_frames' do
        objects = 20.times.map do |i|
          OpenStruct.new(time_frame: time_frame.shift_by((5 * i).days))
        end
        tree = TimeFrame::Collection.new(objects) { |item| item.time_frame }
        interval = TimeFrame.new(min: time, duration: 1.hour)

        result = tree.all_intersecting(interval.shift_by((-1).day))
        expect(result).to eq []

        result = tree.all_intersecting(interval)
        expected_result = objects.select do |object|
          !(object.time_frame & (interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(5.days)
        result = tree.all_intersecting(this_interval)
        expected_result = objects.select do |object|
          !(object.time_frame & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(7.days)
        result = tree.all_intersecting(this_interval)
        expected_result = objects.select do |object|
          !(object.time_frame & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(17.days)
        result = tree.all_intersecting(this_interval)
        expected_result = objects.select do |object|
          !(object.time_frame & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        this_interval = interval.shift_by(42.days)
        result = tree.all_intersecting(this_interval)
        expected_result = objects.select do |object|
          !(object.time_frame & (this_interval)).empty?
        end
        expect(result).to eq expected_result

        result = tree.all_intersecting(interval.shift_by(300.days))
        expect(result).to eq []

      end
    end
  end
end
