FactoryBot.define do
    factory :task do
        association :project
        association :creator, factory: :user
        association :assignee, factory: :user
        # association :parent, factroy: :task
        title { "rails Assignment" }
        description { "library management system in rails" }
        status  { "todo" }
        priority  { "low" }
        due_date { Time.zone.today + 6.days }
        deleted_at { nil }
    end
    factory :task1, class: 'Task' do
        association :project
        association :creator, factory: :user
        association :assignee, factory: :user
        # association :parent, factroy: :task
        title { "rails Assignment" }
        description { "library management system in rails" }
        status  { "todo" }
        priority  { "low" }
        due_date { Time.zone.today }
        deleted_at { nil }
    end
    factory :task2, class: 'Task' do
        association :project
        association :creator, factory: :user
        association :assignee, factory: :user
        # association :parent, factroy: :task
        title { "rails Assignment" }
        description { "library management system in rails" }
        status  { "todo" }
        priority  { "low" }
        due_date { Time.zone.today-6 }
        deleted_at { nil }
          trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
    end
end
