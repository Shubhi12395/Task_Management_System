FactoryBot.define do
  factory :comment do
    content { "MyText" }
    association :commentable, factory: :user
    trait :for_task do
      association :commentable, factory: :task
    end
  end
end
