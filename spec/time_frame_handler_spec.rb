require 'spec_helper'
require 'models/vogon_poem'

describe TimeFrame::Handler do
  let(:time_frame) { TimeFrame.new(min: 5.days.ago, duration: 20.days) }
  let!(:poem_min){ VogonPoem.create(written_at: time_frame.min) }
  let!(:poem_max){ VogonPoem.create(written_at: time_frame.max) }

  it 'should return all records between min and max' do
    expect(VogonPoem.where(written_at: time_frame).count).to eq 2
    expect(VogonPoem.where(written_at: time_frame).first).to eq poem_min
    expect(VogonPoem.where(written_at: time_frame).last).to eq poem_max
  end
end