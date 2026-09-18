class DueTaskEmailJob < ApplicationJob
  queue_as :default

  def perform
    Task.where(due_date: Date.tomorrow, status: 0..1).each do |task|
     next unless task.assignee
      TaskMailer.overdue_task(task.assignee, task).deliver_later
    end
  end
end
