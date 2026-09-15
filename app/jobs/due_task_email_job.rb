class DueTaskEmailJob < ApplicationJob
  queue_as :default

  def perform
    Task.where(due_date: Date.tomorrow, status: 0..1).each do |task|
      TaskMailer.overdue_task(task.assignee, task).deliver_later
      #  DueTaskEmailJob.perform_later
    end
  end
end
