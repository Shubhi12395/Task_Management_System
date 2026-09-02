FactoryBot.define do
    factory :task do
        association :user
        title {"rails Assignment"}
        description {"library management system in rails"}
        completed  {true}
        priority  {"low"}
        due_date {Time.zone.today + 6.days}
        deleted_at {nil}
    end
end
