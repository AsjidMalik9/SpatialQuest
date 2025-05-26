require 'rails_helper'

RSpec.describe Quest, type: :model do
  describe 'geo-fencing' do
    let(:campus_boundary) do
      {
        type: 'Polygon',
        coordinates: [[
          [-122.4194, 37.7749],  # San Francisco coordinates
          [-122.4194, 37.7849],
          [-122.4094, 37.7849],
          [-122.4094, 37.7749],
          [-122.4194, 37.7749]   # Close the polygon
        ]]
      }.to_json
    end

    let!(:campus_quest) do
      create(:quest,
        name: 'Campus Quest',
        status: 'active',
        latitude: 37.7799,
        longitude: -122.4144,
        boundary: campus_boundary
      )
    end

    let!(:outside_quest) do
      create(:quest,
        name: 'Outside Quest',
        status: 'active',
        latitude: 37.7849,
        longitude: -122.4294,
        boundary: {
          type: 'Polygon',
          coordinates: [[
            [-122.4294, 37.7849],
            [-122.4294, 37.7949],
            [-122.4194, 37.7949],
            [-122.4194, 37.7849],
            [-122.4294, 37.7849]
          ]]
        }.to_json
      )
    end

    describe '.containing_point' do
      it 'finds quests containing the given point' do
        # Point inside campus quest
        inside_point_quests = Quest.containing_point(37.7799, -122.4144)
        expect(inside_point_quests).to include(campus_quest)
        expect(inside_point_quests).not_to include(outside_quest)
      end

      it 'returns empty when point is outside all quests' do
        # Point outside both quests
        outside_point_quests = Quest.containing_point(37.7949, -122.4394)
        expect(outside_point_quests).to be_empty
      end
    end

    describe '#contains_point?' do
      it 'returns true for points inside the boundary' do
        expect(campus_quest.contains_point?(37.7799, -122.4144)).to be true
      end

      it 'returns false for points outside the boundary' do
        expect(campus_quest.contains_point?(37.7949, -122.4394)).to be false
      end
    end
  end
end
