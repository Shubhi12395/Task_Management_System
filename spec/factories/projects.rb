FactoryBot.define do
  factory :project do
    association :user
    name { "MyString" }
    description { "MyString projects is coming" }
    status { "in_progress" }
    due_date { Time.zone.today + 6.days }
  end
end
