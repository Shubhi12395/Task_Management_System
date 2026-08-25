require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:valid_headers) { { "Authorization" => "Bearer #{token}" } }
  let(:invalid_headers) { { "Authorization" => "Bearer invalid_token_here" } }
  
  def json_response
    JSON.parse(response.body)
  end
  
  describe "POST /api/v1/tasks" do 
    let(:valid_params) do
      { 
        task: { 
          title: "Rails Assignment", 
          description: "blood bank management system", 
          completed: true, 
          priority: "medium", 
          due_date: "30/08/2026" 
        } 
      }
    end

    context "with a valid JWT token" do
      it "creates a task assigned to the logged-in user" do 
        expect {
          post '/api/v1/tasks', params: valid_params, headers: valid_headers
        }.to change(user.tasks, :count).by(1) 
        
        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq('Task created successfully') 
        expect(json_response['task']['user_id']).to eq(user.id) 
      end 
    end

    context "without a valid JWT token" do
      it "returns a 401 unauthorized status" do
        post '/api/v1/tasks', params: valid_params, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized) 
      end
      
      it "returns 401 unauthorized if headers are completely missing" do
        post '/api/v1/tasks', params: valid_params, headers: {}
        expect(response).to have_http_status(:unauthorized)
      end
    end 
  end

  describe "GET /api/v1/tasks" do 
    let!(:user_tasks) { create_list(:task, 25, user: user) }
    let!(:other_task) { create(:task) } 

    context "with a valid JWT token" do
      it "shows task with valid web token" do
        get '/api/v1/tasks', headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it "paginates the tasks and returns the Pagy 'meta' key" do
        get '/api/v1/tasks', headers: valid_headers
        expect(json_response).to have_key('meta')
        expect(json_response.dig('meta', 'count')).to eq(25)
      end
    end

    context "without a valid JWT token" do
      it "returns a 401 unauthorized status" do
        get '/api/v1/tasks', headers: invalid_headers
        expect(response).to have_http_status(:unauthorized) 
      end
      
      it "returns 401 unauthorized if headers are completely missing" do
        get '/api/v1/tasks', headers: {}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end 

  describe "GET /api/v1/tasks/:id" do
    let!(:my_task) { create(:task, user: user) }
    let!(:someone_elses_task) { create(:task) } 

    context "with a valid JWT token" do
      context "when the task belongs to the user" do
        it "returns the task details successfully" do
          get "/api/v1/tasks/#{my_task.id}", headers: valid_headers
          
          expect(response).to have_http_status(:ok)
          expect(json_response['id']).to eq(my_task.id)
          expect(json_response['title']).to eq(my_task.title)
          expect(json_response['description']).to eq(my_task.description)
          expect(json_response['completed']).to eq(my_task.completed)
          expect(json_response['priority']).to eq(my_task.priority)
        end
      end
      
      context "when the task belongs to a different user" do
        it "returns a 404 not found status" do
          get "/api/v1/tasks/#{someone_elses_task.id}", headers: valid_headers
          
          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq("Task not found")
        end
      end
      
      context "when the task ID does not exist at all" do
        it "returns a 404 not found status" do
          get "/api/v1/tasks/999999", headers: valid_headers
          
          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq("Task not found")
        end
      end
    end
    
    context "without a valid JWT token" do
      it "returns a 401 unauthorized status" do
        get "/api/v1/tasks/#{my_task.id}", headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT/PATCH /api/v1/tasks/:id" do
    let!(:my_task) { create(:task, user: user) }
    let!(:someone_elses_task) { create(:task) } 
    
    let(:valid_update_params) do
      { 
        task: { 
          title: "Rails Updated Assignment", 
          description: "blood bank management system", 
          completed: true, 
          priority: "medium", 
          due_date: "30/08/2026" 
        } 
      }
    end

    let(:invalid_update_params) do
      {
        task: {
          title: "" 
        }
      }
    end

    context "with a valid JWT token" do
      context "when the task belongs to the logged-in user" do
        context "with valid parameters" do
          it "updates the task and returns a success message" do
            patch "/api/v1/tasks/#{my_task.id}", params: valid_update_params, headers: valid_headers
            
            expect(response).to have_http_status(:ok)
            expect(json_response['message']).to eq('Task updated successfully')
            expect(json_response['task']['title']).to eq("Rails Updated Assignment")
          end
        end
        
        context "with invalid parameters" do
          it "returns a 422 unprocessable entity status with errors" do
            patch "/api/v1/tasks/#{my_task.id}", params: invalid_update_params, headers: valid_headers
            
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response).to have_key('title') 
          end
        end
      end
      
      context "when the task belongs to a different user" do
        it "rescues ActiveRecord::RecordNotFound and returns a 404 status" do
          patch "/api/v1/tasks/#{someone_elses_task.id}", params: valid_update_params, headers: valid_headers
          
          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq("Task not found")
        end
      end
      
      context "when the task ID does not exist" do
        it "rescues ActiveRecord::RecordNotFound and returns a 404 status" do
          patch "/api/v1/tasks/999999", params: valid_update_params, headers: valid_headers
          
          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq("Task not found")
        end
      end
    end

    context "without a valid JWT token" do
      it "returns a 401 unauthorized status" do
        patch "/api/v1/tasks/#{my_task.id}", params: valid_update_params, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
      
      it "returns a 401 unauthorized status if headers are missing" do
        patch "/api/v1/tasks/#{my_task.id}", params: valid_update_params, headers: {}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
    describe "DELETE /api/v1/tasks/:id" do
    let!(:my_task) { create(:task, user: user) }
    let!(:someone_elses_task) { create(:task) }

    context "with a valid JWT token" do
      context "when the task belongs to the logged-in user" do
        it "deletes the task and returns a success message" do
          expect {
            delete "/api/v1/tasks/#{my_task.id}", headers: valid_headers
          }.to change(user.tasks, :count).by(-1)

          expect(response).to have_http_status(:ok)
          expect(json_response['message']).to eq('Task deleted successfully')
          expect(json_response['task']['id']).to eq(my_task.id)
          
          expect(Task.exists?(my_task.id)).to be_falsey
        end
      end

      context "when the task belongs to a different user" do
        it "rescues ActiveRecord::RecordNotFound, skips deletion, and returns 404" do
          expect {
            delete "/api/v1/tasks/#{someone_elses_task.id}", headers: valid_headers
          }.not_to change(Task, :count)

          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq("Task not found")
        end
      end

      context "when the task ID does not exist at all" do
        it "returns a 404 not found status" do
          delete "/api/v1/tasks/999999", headers: valid_headers

          expect(response).to have_http_status(:not_found)
          expect(json_response['error']).to eq("Task not found")
        end
      end
    end

    context "without a valid JWT token" do
      it "returns a 401 unauthorized status" do
        delete "/api/v1/tasks/#{my_task.id}", headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns a 401 unauthorized status if headers are completely missing" do
        delete "/api/v1/tasks/#{my_task.id}", headers: {}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
