FactoryBot.define do
  factory :user do
    name { "Jain" }
    sequence(:email) { |n| "user#{n}@example.com" } 
    password { "12345667" }
  end
end
