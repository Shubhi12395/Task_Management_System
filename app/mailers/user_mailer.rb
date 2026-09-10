class UserMailer < ApplicationMailer
  default from: "shubhijain968542@gmail.com"
  def welcome_email
    @user = params[:user]
    mail(to: @user.email, subject: "Welcome User")
  end
  def otp_send
      @user=params[:user]
    mail(to: @user.email, subject: "verification email") do |format|
      format.html {
      render html: "<h1>Hello #{@user.name}!</h1><p>Your otp  is #{@user.otp_code} and expired at #{@user.otp_expires_at}.</p>".html_safe }
    end
  end
end
