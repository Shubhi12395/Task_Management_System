require 'swagger_helper'

RSpec.describe 'Profiles API Documentation', type: :request, swagger: true  do
  let(:user_record) { User.first || User.create!(name: 'Test', email: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user_record.id) }
   let(:Authorization) { "Bearer #{token}" }
   before do
    user_record.update!(refresh_token: token)
  end
  path '/api/v1/users/me' do
    get 'Retrieves current user profile' do
      tags 'Profiles'
      security [ Bearer: {} ]
      produces 'application/json'

      response '200', 'successfully shows the user profile' do
        run_test!
      end
    end

    patch 'Updates current user profile' do
      tags 'Profiles'
      security [ Bearer: {} ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :profile_data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'shubhi' },
              email: { type: :string, example: 'shubhi2345@gmail.com' },
              password: { type: :string, example: 'shubhi1234' }
            }
          }
        },
        required: [ 'user' ]
      }

      response '200', 'Profile updated successfully' do
        let(:profile_data) { { user: { name: 'shubhi', email: 'shubhi2345@gmail.com', password: 'shubhi1234' } } }
        run_test!
      end

      response '422', 'returns error when invalid details are entered' do
        let(:profile_data) { { user: { name: '' } } }
        run_test!
      end
    end
  end

  path '/api/v1/users/me/avatar' do
    post 'Uploads an avatar image' do
      tags 'Profiles'
      security [ Bearer: {} ]
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :avatar, in: :formData, type: :file, description: 'The avatar image file to upload'

      response '200', 'Avatar uploaded successfully' do
        let(:avatar) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test_avatar.png'), 'image/png') }
        run_test!
      end

      response '422', 'Failed to save avatar attachment' do
        let(:avatar) { nil }
        run_test!
      end
    end
  end
end
