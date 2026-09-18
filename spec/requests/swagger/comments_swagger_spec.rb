require 'swagger_helper'

RSpec.describe 'Comments API Documentation', type: :request, swagger: true do
  let(:user_record) { User.first || User.create!(name: 'Test', email: 'test@example.com', password: 'password123') }
  let(:token) { JsonWebToken.encode(user_id: user_record.id) }
  let(:Authorization) { "Bearer #{token}" }
  before do
    user_record.update!(refresh_token: token)
  end
  let(:project_record) { Project.first || Project.create!(name: 'Proj', description: 'this is rails project', user: user_record) }
  let(:task_record) { Task.first || create(:task, project: project_record, creator: user_record) }

  path '/api/v1/users/comments' do
    post 'Creates a comment on the logged-in user' do
      tags 'User Comments'
      security [ Bearer: {} ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :comment_data, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              content: { type: :string, example: 'New Automated Task' }
            },
            required: [ 'content' ]
          }
        },
        required: [ 'comment' ]
      }

      response '201', 'Comment created successfully' do
        let(:comment_data) { { comment: { content: 'New Automated Task' } } }
        run_test!
      end
    end

    get 'Lists and paginates comments belonging to the logged-in user' do
      tags 'User Comments'
      security [ Bearer: {} ]
      produces 'application/json'

      response '200', 'Success with Pagy metadata framework' do
        run_test!
      end
    end
  end

  path '/api/v1/users/comments/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Comment ID'

    delete 'Deletes a user comment' do
      tags 'User Comments'
      security [ Bearer: {} ]
      produces 'application/json'

      response '200', 'comment deleted successfully' do
        let(:id) { Comment.create!(content: 'Delete me', commentable: user_record).id }
        run_test!
      end

      response '404', 'Comment not found' do
        let(:id) { 999999 }
        run_test!
      end
    end
  end

  path '/api/v1/tasks/{task_id}/comments' do
    parameter name: :task_id, in: :path, type: :integer, description: 'Task description rails'

    post 'Creates a comment on a specific task' do
      tags 'Task Comments'
      security [ Bearer: {} ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :comment_data, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              content: { type: :string, example: 'New Automated Task' }
            },
            required: [ 'content' ]
          }
        },
        required: [ 'comment' ]
      }

      response '201', 'Comment created successfully' do
        let(:task_id) { task_record.id }
        let(:comment_data) { { comment: { content: 'New Automated Task' } } }
        run_test!
      end
    end

    get 'Lists and paginates comments belonging to a specific task' do
      tags 'Task Comments'
      security [ Bearer: {} ]
      produces 'application/json'

      response '200', 'Success with Pagy metadata framework' do
        let(:task_id) { task_record.id }
        run_test!
      end
    end
  end

  path '/api/v1/tasks/{task_id}/comments/{id}' do
    parameter name: :task_id, in: :path, type: :integer, description: 'Task ID'
    parameter name: :id, in: :path, type: :integer, description: 'Comment ID'

    delete 'Deletes a task comment' do
      tags 'Task Comments'
      security [ Bearer: {} ]
      produces 'application/json'

      response '200', 'comment deleted successfully' do
        let(:task_id) { task_record.id }
        let(:id) { Comment.create!(content: 'Delete me task', commentable: task_record).id }
        run_test!
      end

      response '404', 'Comment not found' do
        let(:task_id) { task_record.id }
        let(:id) { 999999 }
        run_test!
      end
    end
  end
end
