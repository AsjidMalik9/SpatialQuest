require 'rails_helper'

RSpec.describe Quest, type: :model do
  describe 'geo-fencing' do
    let(:user) { create(:user, latitude: 37.7799, longitude: -122.4144) }
    
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

    describe '.near_user' do
      it 'finds quests containing the user location' do
        nearby_quests = Quest.near_user(user)

        expect(nearby_quests).to include(campus_quest)
        expect(nearby_quests).not_to include(outside_quest)
      end

      it 'returns empty when user has no location' do
        user.update(latitude: nil, longitude: nil)
        expect(Quest.near_user(user)).to be_empty
      end

      it 'returns empty when user is outside all quests' do
        user.update(latitude: 37.7949, longitude: -122.4394)
        expect(Quest.near_user(user)).to be_empty
      end
    end

    describe '#contains_point?' do
      it 'returns true for points inside the boundary' do
        expect(campus_quest.contains_point?(37.7799, -122.4144)).to be true
      end

      it 'returns false for points outside the boundary' do
        expect(campus_quest.contains_point?(37.7949, -122.4394)).to be false
      end

      it 'returns false when boundary is nil' do
        campus_quest.update(boundary: nil)
        expect(campus_quest.contains_point?(37.7799, -122.4144)).to be false
      end
    end
  end
end
