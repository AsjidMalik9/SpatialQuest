FactoryBot.define do
  factory :quest_asset do
    association :quest
    association :asset
    latitude { 37.7749 }
    longitude { -122.4194 }
    status { 'available' }
    hint { 'Look for this asset' }
    quest_specific_content { 'Quest specific content' }

    trait :collected do
      status { 'collected' }
      collected_at { Time.current }
    end

    trait :placed do
      status { 'placed' }
      placed_at { Time.current }
    end
  end
end 