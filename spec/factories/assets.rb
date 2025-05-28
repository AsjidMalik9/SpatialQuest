FactoryBot.define do
  factory :asset do
    sequence(:name) { |n| "Asset #{n}" }
    content { "MyText" }

    trait :with_quest do
      after(:create) do |asset|
        create(:quest_asset, asset: asset, quest: create(:quest))
      end
    end

    trait :collected do
      after(:create) do |asset|
        create(:quest_asset, :collected, asset: asset, quest: create(:quest))
      end
    end

    trait :placed do
      after(:create) do |asset|
        create(:quest_asset, :placed, asset: asset, quest: create(:quest))
      end
    end
  end
end
