# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { create(:user, password: "password123", password_confirmation: "password123") }

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
    let(:login_url) { '/api/v1/auth/login' }

    context "with valid credentials" do
      it "logs in the user and returns a token" do
        post login_url, params: { email: user.email, password: "password123" }

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("login successfully")
        expect(json_response['token']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns a 401 unauthorized status for a non-existent email" do
        post login_url, params: { email: "noexistemail.com", password: "password123" }

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Invalid email")
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
end
