FactoryBot.define do
  factory :comment do
    association :commentable, factory: :user
    association :commentable, factory: :task
    content { "MyText" }
  end
end
