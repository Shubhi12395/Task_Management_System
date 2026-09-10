require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project, creator: user) }
  let(:comment) { create(:comment, commentable: user) }
  let(:comments) { create(:comment, commentable: task) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:valid_headers) { { "Authorization" => "Bearer #{token}" } }
  
  def json_response
    JSON.parse(response.body)
  end
  
  let(:valid_payload) do
    {
    comment: {
    content: "New Automated Task" } }
  end
  
  describe "POST /users/comments" do
    context "with a valid JWT token" do
      it "creates a comment on the logged-in user" do
        expect {
        post '/api/v1/users/comments', params: valid_payload, headers: valid_headers}.to change(user.comments, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq("Comment created successfully")
        expect(Comment.last.commentable_type).to eq("User")
        expect(Comment.last.commentable_id).to eq(user.id)
      end
    end
  end
  
  describe "POST /tasks/:task_id/comments" do
    context "with a valid JWT token"  do
      it "creates a comment on the logged-in user" do
        expect {
        post "/api/v1/tasks/#{task.id}/comments", params: valid_payload, headers: valid_headers}.to change(task.comments, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq("Comment created successfully")
        expect(Comment.last.commentable_type).to eq("Task")
        expect(Comment.last.commentable_id).to eq(task.id)
      end
    end
  end
  
  describe "GET /users/comments" do
    let!(:comments) do
      Array.new(25) do
        Comment.create!(content: "Test comment", commentable: user)
      end
    end
    context "with a valid JWT token" do
      it "shows task with valid web token" do
        get '/api/v1/users/comments', headers: valid_headers
        expect(response).to have_http_status(:ok)
      end
    end
    it "paginates the tasks and returns the Pagy 'meta' key" do
      get '/api/v1/users/comments', headers: valid_headers
      expect(json_response).to have_key('meta')
      expect(json_response.dig('meta', 'count')).to eq(25)
    end
  end
  
  describe "GET /task/:task_id/comments" do
    let!(:comments) do
      Array.new(25) do
        Comment.create!(content: "Test comment",commentable: task)
      end
    end
    context "with a valid JWT token" do
      it "shows task with valid web token" do
        get "/api/v1/tasks/#{task.id}/comments", headers: valid_headers
        expect(response).to have_http_status(:ok)
      end
    end
    it "paginates the tasks and returns the Pagy 'meta' key" do
      get "/api/v1/tasks/#{task.id}/comments", headers: valid_headers
      expect(json_response).to have_key('meta')
      expect(json_response.dig('meta', 'count')).to eq(25)
    end
  end
  
  describe "DELETE /api/v1/users/comments/:id" do
    let!(:comment) { create(:comment, commentable: user) }
    let!(:someone_elses_comment) { create(:comment) }
    
    context "with a valid JWT token" do
      context "when the comment belongs to the logged-in user" do
        it "deletes the comment and returns a success message" do
          expect { delete "/api/v1/users/comments/#{comment.id}", headers: valid_headers }.to change(Comment, :count).by(-1)
          expect(response).to have_http_status(:ok)
          expect(json_response['message']).to eq('comment deleted successfully')
          expect(Comment.exists?(comment.id)).to be_falsey
        end
      end
    end
    context "when the comment belongs to a different user" do
      it "rescues ActiveRecord::RecordNotFound, skips deletion, and returns 404" do
        expect { delete "/api/v1/users/comments/#{someone_elses_comment.id}", headers: valid_headers }.not_to change(Comment, :count)
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq("Comment not found")
      end
    end
  end
  
  describe "DELETE /api/v1/tasks/task_id/comments/:id" do
    let!(:comment) { create(:comment, commentable: task) }
    let!(:someone_elses_comment) { create(:comment) }
    
    context "with a valid JWT token" do
      context "when the comment belongs to the logged-in user" do
        it "deletes the comment and returns a success message" do
          expect { delete "/api/v1/tasks/#{task.id}/comments/#{comment.id}", headers: valid_headers }.to change(Comment, :count).by(-1)
          expect(response).to have_http_status(:ok)
          expect(json_response['message']).to eq('comment deleted successfully')
          expect(Comment.exists?(comment.id)).to be_falsey
        end
      end
    end
    
    context "when the comment belongs to a different task" do
      it "rescues ActiveRecord::RecordNotFound, skips deletion, and returns 404" do
        expect { delete "/api/v1/tasks/#{task.id}/comments/#{someone_elses_comment.id}", headers: valid_headers }.not_to change(Comment, :count)
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq("Comment not found")
      end
    end
  end
end
