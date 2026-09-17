# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { create(:user, name: "shubhi", password: "password123", email: "shubhi123@gmail.com", failed_attempts: 0) }

  describe "POST /api/v1/auth/signup" do
    context "with valid parameters" do
      it "creates a new user, enqueues an email, and returns JSON data" do
        expect {
          post '/api/v1/auth/signup', params: {
            user: { name: "shubhi", email: "shubhi2345@gmail.com", password: "password123" }
          }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('User created and mail sent successfully')
        expect(json_response['token']).to be_present
        expect(json_response['user']['email']).to eq("shubhi2345@gmail.com")
      end
    end

    context "with invalid parameters" do
      it "returns a 422 unprocessable entity with error messages" do
        post '/api/v1/auth/signup', params: {
          user: { name: "shubhi", email: "shubhi2345@gmail.com", password: "123" }
        }
        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).not_to be_empty
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "logs in the user and returns a token" do
        post '/api/v1/auth/login', params: { email: user.email, password: "password123" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("login successfully")
        expect(json_response['token']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns a 422 status for a non-existent email" do
        post '/api/v1/auth/login', params: { email: "noexistemail.com", password: "password123" }
        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Invalid email")
      end

      it "increments the failed attempts counter on wrong password" do
        expect {
          post '/api/v1/auth/login', params: { email: user.email, password: "wrongpassword" }
        }.to change { user.reload.failed_attempts }.by(1)

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("please enter correct password")
      end

      it "locks the account out when failed attempts reach 5 or more" do
        user.update!(failed_attempts: 5)

        post '/api/v1/auth/login', params: { email: user.email, password: "password123" }

        expect(response).to have_http_status(:too_many_requests)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("account locked due to maximum attempts failed")
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:headers) { { "Authorization" => "Bearer #{token}" } }

    it "successfully logs out the user and returns a confirmation message" do
      delete '/api/v1/auth/logout', headers: headers
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('User logout successfully')
    end
  end

  describe "PATCH /api/v1/auth/password_reset" do
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:headers) { { "Authorization" => "Bearer #{token}" } }

    context "with correct current password credentials" do
      it "updates the password successfully" do
        patch '/api/v1/auth/password_reset',
          params: { user: { email: user.email, current_password: "password123", new_password: "newsecurepassword123" } },
          headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('password update successfully')
        expect(user.reload.authenticate("newsecurepassword123")).to be_truthy
      end
    end

    context "with an incorrect current password" do
      it "returns a 401 unauthorized status code" do
        patch '/api/v1/auth/password_reset', params: { user: { email: user.email, current_password: "wrongoldpassword", new_password: "newsecurepassword123" } }, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Incorrect current password')
      end
    end
  end

  describe "POST /api/v1/auth/forgot_password" do
    context "with a registered email" do
      it "generates an OTP code and schedules an email delivery job" do
        expect {
          post '/api/v1/auth/forgot_password', params: { user: { email: user.email } }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('otp send to the email')

        user.reload
        expect(user.otp_code).to be_present
        expect(user.otp_expires_at).to be_present
      end
    end

    context "with an unregistered email" do
      it "returns a 404 not found status" do
        post '/api/v1/auth/forgot_password', params: { user: { email: "fakeuser@notreal.com" } }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email')
      end
    end
  end

  describe "PATCH /api/v1/auth/forgot_password/reset" do
    context "using an active and valid OTP token" do
      it "resets the password and deletes the security parameters from the user" do
        user.update!(otp_code: 1234, otp_expires_at: 10.minutes.from_now)
        patch '/api/v1/auth/forgot_password/reset', params: { otp: 1234, user: { email: user.email, password: "freshpassword123" } }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('password updated successfully')

        user.reload
        expect(user.otp_code).to be_nil
        expect(user.otp_expires_at).to be_nil
        expect(user.authenticate("freshpassword123")).to be_truthy
      end
    end

    context "using an expired OTP token value" do
      it "returns a 410 gone status message" do
        user.update!(otp_code: 1234, otp_expires_at: 5.minutes.ago)

        patch '/api/v1/auth/forgot_password/reset', params: { user: { email: user.email, new_password: "freshpassword123" }, otp: 1234 }

        expect(response).to have_http_status(:gone)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to include('Your OTP has expired')
      end
    end
  end
end
