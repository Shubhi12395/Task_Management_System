class UserMailer < ApplicationMailer
     default from: "shubhijain968542@gmail.com"
     def welcome_email
    @user = params[:user]
    mail(to: @user.email, subject: "Welcome User")
  end
end
