require 'spec_helper'
require 'models/vogon_poem'

describe TimeFrame::PredicateBuilderHandler do
  TimeFrame::PredicateBuilderHandler.new(VogonPoem)

  let(:time_frame) { TimeFrame.new(min: 5.days.ago, duration: 20.days) }

  before { VogonPoem.delete_all }

  it 'returns all records between min and max' do
    poem_min = VogonPoem.create(written_at: time_frame.min)
    poem_max = VogonPoem.create(written_at: time_frame.max)

    result = VogonPoem.where(written_at: time_frame)

    expect(result.count).to eq 2
    expect(result.first).to eq poem_min
    expect(result.last).to eq poem_max
  end

  it 'ignores records outside of min and max' do
    poem_min = VogonPoem.create(written_at: time_frame.min + 1.minute)
    VogonPoem.create(written_at: time_frame.min - 2.years)
    VogonPoem.create(written_at: time_frame.max + 1.month)

    result = VogonPoem.where(written_at: time_frame)

    expect(result.count).to eq 1
    expect(result.first).to eq poem_min
  end

  it 'handles items close to the borders correctly' do
    poem_min = VogonPoem.create(written_at: time_frame.min + 1.second)
    VogonPoem.create(written_at: time_frame.min - 1.second)
    VogonPoem.create(written_at: time_frame.max + 1.second)

    result = VogonPoem.where(written_at: time_frame)

    expect(result.count).to eq 1
    expect(result.first).to eq poem_min
  end
end
