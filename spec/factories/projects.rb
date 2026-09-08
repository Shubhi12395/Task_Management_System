FactoryBot.define do
  factory :project do
    name { "MyString" }
    description { "MyString" }
    status { 1 }
    due_date { "2026-09-04" }
    user { nil }
  end
end
