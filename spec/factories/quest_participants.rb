FactoryBot.define do
  factory :quest_participant do
    association :quest
    association :user
    status { "active" }
  end
end
