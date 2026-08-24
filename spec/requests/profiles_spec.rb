# spec/requests/profiles_spec.rb
require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let!(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/users/me" do 
    it "successfully shows the user profile" do
      get '/api/v1/users/me', headers: headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
    end
  end

  describe "PATCH /api/v1/users/me" do 
    it "successfully updates the profile" do
      patch '/api/v1/users/me', params: { user: { name: "shubhi", email: "shubhi2345@gmail.com" , password: "shubhi1234"} }, headers: headers
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq("Profile updated successfully")
    end

    it "returns error when invalid details are entered" do
patch '/api/v1/users/me', params: { user: { name: "" } }, headers: headers
      
      expect(response).to have_http_status(:unprocessable_content)
      
      json_response = JSON.parse(response.body)
      expect(json_response['errors']).to be_present 
    end
  end

  describe "POST /api/v1/users/me/avatar" do 
    context "with a valid image file file upload" do
      let(:file) { fixture_file_upload('test_avatar.png', 'image/png') }

      it "attaches the image file and returns the attachment URL" do
        post '/api/v1/users/me/avatar', params: { avatar: file }, headers: headers

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq("Avatar uploaded successfully")
        expect(json_response['avatar']).to be_present
        expect(user.reload.avatar.attached?).to be_truthy
      end
    end

    context "when upload fails due to missing file" do
      it "returns an unprocessable status error" do
        post '/api/v1/users/me/avatar', params: { avatar: nil }, headers: headers

        expect(response).to have_http_status(:unprocessable_content)
        
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq("Failed to save avatar attachment")
      end
    end
  end
end
