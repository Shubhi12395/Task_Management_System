class TaskMailer < ApplicationMailer
    default from: "shubhijain968542@gmail.com"
    def overdue_task(user, task)
        @user = user
        @task = task

        mail(to: @user.email, subject: "Your task is overdue!") do |format|
            format.text { render plain: "Hello, your task '#{@task.title}' is overdue." }
        end
    end
end
