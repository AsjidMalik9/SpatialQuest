FactoryBot.define do
  factory :quest do
    sequence(:name) { |n| "Quest #{n}" }
    description { "A fun quest" }
    status { "active" }
    latitude { 37.7749 }
    longitude { -122.4194 }
    boundary do
      {
        type: 'Polygon',
        coordinates: [[
          [-122.4194, 37.7749],
          [-122.4194, 37.7849],
          [-122.4094, 37.7849],
          [-122.4094, 37.7749],
          [-122.4194, 37.7749]
        ]]
      }.to_json
    end
  end
end
