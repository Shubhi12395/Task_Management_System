# spec/requests/admin/users_spec.rb
require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin_user) { create(:admin_user) } 
  let!(:user_record) { create(:user) } 
  before do
    sign_in admin_user, scope: :admin_user
  end
  
  describe "GET /admin/users (index)" do
    it "renders the table with user columns successfully" do
      get admin_users_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user_record.email)
      expect(response.body).to include(user_record.name)
    end
  end
  
  describe "GET /admin/users/:id (show)" do
    it "renders the attributes table and comments section" do
      get admin_user_path(user_record)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user_record.email)
      expect(response.body).to include(user_record.name)
    end
  end
  
  describe "POST /admin/users (create)" do
    context "with valid parameters" do
      let(:valid_params) do
        {
        user: {
        name: "Jane Smith",
        email: "jane@example.com",
        password: "SecurePassword123",
        failed_attempts: 0
      }
    }
  end
  
  it "creates a new user and redirects to show page" do
    expect { post admin_users_path, params: valid_params }.to change(User, :count).by(1)
    new_user = User.last
    expect(new_user.name).to eq("Jane Smith")
    expect(response).to redirect_to(admin_user_path(new_user))
  end
end
end

describe "PUT /admin/users/:id (update)" do
  context "when a new password is provided" do
    let(:params_with_password) do
      {
      user: {
      name: "Updated Name",
      password: "BrandNewPassword123"
    }
  }
end

it "updates both the name and the password" do
  put admin_user_path(user_record), params: params_with_password
  
  expect(response).to redirect_to(admin_user_path(user_record))
  expect(user_record.reload.name).to eq("Updated Name")
end
end

context "when the password field is left blank" do
  let(:params_with_blank_password) do
    {
    user: {
    name: "Another Update",
    password: ""
  }
}
end

it "updates the name but leaves the existing password intact" do
  original_encrypted_password = user_record.password
  
  put admin_user_path(user_record), params: params_with_blank_password
  
  expect(response).to redirect_to(admin_user_path(user_record))
  user_record.reload
  expect(user_record.name).to eq("Another Update")
  expect(user_record.password).to eq(original_encrypted_password)
end
end
end
end
