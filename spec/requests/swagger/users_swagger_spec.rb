require 'swagger_helper'

RSpec.describe 'Api::V1::Users API', type: :request, swagger: true  do
  path '/api/v1/auth/signup' do
    post 'Registers a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
      type: :object,
      properties: {
      user: {
      type: :object,
      properties: {
      name: { type: :string, example: 'John Doe' },
      email: { type: :string, example: 'john@example.com' },
      password: { type: :string, example: 'password123' }
    },
    required: [ 'name', 'email', 'password' ]
  }
},
required: [ 'user' ]
}

response '201', 'User created and mail sent successfully' do
  let(:user) { { user: { name: 'John Doe', email: 'john@example.com', password: 'password123' } } }
  run_test!
end

response '422', 'unprocessable entity (validation errors)' do
  let(:user) { { user: { name: '', email: 'invalid-email', password: '' } } }
  run_test!
end
end
end

path '/api/v1/auth/login' do
  post 'Logs in a user' do
    tags 'Users'
    consumes 'application/json'
    produces 'application/json'

    parameter name: :credentials, in: :body, schema: {
    type: :object,
    properties: {
    email: { type: :string, example: 'john@example.com' },
    password: { type: :string, example: 'password123' }
  },
  required: [ 'email', 'password' ]
}

response '200', 'login successfully' do
  before { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
  let(:credentials) { { email: 'john@example.com', password: 'password123' } }
  run_test!
end

response '401', 'please enter correct password' do
  before { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
  let(:credentials) { { email: 'john@example.com', password: 'wrongpassword' } }
  run_test!
end

response '422', 'Invalid email' do
  let(:credentials) { { email: 'notfound@example.com', password: 'password' } }
  run_test!
end
end
end

path '/api/v1/auth/logout' do
  delete 'Logs out the current user' do
    tags 'Users'
    security [ Bearer: {} ]
    produces 'application/json'

    response '200', 'User logout successfully' do
     let(:user) { create(:user) }
      let(:token) { JsonWebToken.encode(user_id: user.id) }
      let(:Authorization) { "Bearer #{token}" }
      before do
        user.update!(refresh_token: token)
      end
      run_test!
    end
  end
end

path '/api/v1/auth/password_reset' do
  patch 'Resets password for logged-in user' do
    tags 'Users'
    security [ Bearer: {} ]
    consumes 'application/json'
    produces 'application/json'

    parameter name: :password_data, in: :body, schema: {
    type: :object,
    properties: {
    user: {
    type: :object,
    properties: {
    email: { type: :string, example: 'john@example.com' },
    current_password: { type: :string, example: 'password123' },
    new_password: { type: :string, example: 'newsecurepassword' }
  },
  required: [ 'current_password', 'new_password' ]
}
},
required: [ 'user' ]
}

response '200', 'password update successfully' do
  let(:user_record) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
 let(:token) { JsonWebToken.encode(user_id: user_record.id) }
      let(:Authorization) { "Bearer #{token}" }
  let(:password_data) { { user: { email: 'john@example.com', current_password: 'password123', new_password: 'newsecurepassword' } } }
  before do
    user_record.update!(refresh_token: token)
  end
  run_test!
end
end
end

path '/api/v1/auth/forgot_password' do
  post 'Requests an OTP for a forgotten password' do
    tags 'Users'
    consumes 'application/json'
    produces 'application/json'

    parameter name: :email_data, in: :body, schema: {
    type: :object,
    properties: {
    user: {
    type: :object,
    properties: {
    email: { type: :string, example: 'john@example.com' }
  },
  required: [ 'email' ]
}
},
required: [ 'user' ]
}

response '200', 'otp send to the email' do
  before { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
  let(:email_data) { { user: { email: 'john@example.com' } } }
  run_test!
end

response '404', 'Invalid email' do
  let(:email_data) { { user: { email: 'nonexistent@example.com' } } }
  run_test!
end
end
end

path '/api/v1/auth/forgot_password/reset' do
  patch 'Resets password using an OTP token' do
    tags 'Users'
    consumes 'application/json'
    produces 'application/json'

    parameter name: :reset_data, in: :body, schema: {
    type: :object,
    properties: {
    otp: { type: :integer, example: 1234 },
    user: {
    type: :object,
    properties: {
    email: { type: :string, example: 'john@example.com' },
    password: { type: :string, example: 'brandnewpass' }
  },
  required: [ 'email', 'password' ]
}
},
required: [ 'otp', 'user' ]
}

response '200', 'password updated successfully' do
  before do
    User.create!(name: 'John', email: 'john@example.com', password: 'password123', otp_code: 1234, otp_expires_at: 10.minutes.from_now)
  end
  let(:reset_data) { { otp: 1234, user: { email: 'john@example.com', password: 'brandnewpass' } } }
  run_test!
end
end
end
end
