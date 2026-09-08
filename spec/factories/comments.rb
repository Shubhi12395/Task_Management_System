FactoryBot.define do
  factory :comment do
    content { "MyText" }
    commentable { nil }
  end
end
