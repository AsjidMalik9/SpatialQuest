FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    encrypted_password { "password123" }
    latitude { 37.7749 }
    longitude { -122.4194 }
  end
end
