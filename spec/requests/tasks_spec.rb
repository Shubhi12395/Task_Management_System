require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project, creator: user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:valid_headers) { { "Authorization" => "Bearer #{token}" } }
  let(:invalid_headers) { { "Authorization" => "Bearer invalid_token_here" } }


  def json_response
    JSON.parse(response.body)
  end

  describe "POST /api/v1/tasks" do
    let(:assignee) { create(:user) }
    let(:valid_payload) do
  {
    task: {
      title: "New Automated Task",
      description: "Setting up test specs",
      status: "todo",
      priority: "medium",
      due_date: "10/10/2026",
      project_id: project.id,
      assignee_id: assignee.id
    }
  }
end
    context "with a valid JWT token" do
      it "creates a task assigned to the logged-in user" do
        expect {
        post '/api/v1/tasks', params: valid_payload, headers: valid_headers
      }.to change(project.tasks, :count).by(1)
      expect(task.project.user).to eq(task.creator)
      expect(task.creator).not_to eq(task.assignee)
      expect(response).to have_http_status(:created)
      expect(json_response['message']).to eq('Task created successfully')
      expect(Task.last.project_id).to eq(project.id)
    end
  end

  context "without a valid JWT token" do
    it "returns a 401 unauthorized status" do
      post '/api/v1/tasks', params: valid_payload, headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 unauthorized if headers are completely missing" do
      post '/api/v1/tasks', params: valid_payload, headers: {}
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

describe "GET /api/v1/tasks" do
  let!(:user_tasks) { create_list(:task, 25, project: project) }
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
describe "GET /api/v1/tasks/sortby/:sort" do
  let!(:user_tasks) { create_list(:task, 25, project: project) }
  let!(:other_task) { create(:task) }

  context "with a valid JWT token" do
    it "shows task with valid web token" do
      get '/api/v1/tasks/sortby/:sort', headers: valid_headers
      expect(response).to have_http_status(:ok)
    end

    it "paginates the tasks and returns the Pagy 'meta' key" do
      get '/api/v1/tasks/sortby/:sort', headers: valid_headers
      expect(json_response).to have_key('meta')
      expect(json_response.dig('meta', 'count')).to eq(25)
    end
  end

  context "without a valid JWT token" do
    it "returns a 401 unauthorized status" do
      get '/api/v1/tasks/sortby/:sort', headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 unauthorized if headers are completely missing" do
      get '/api/v1/tasks/sortby/:sort', headers: {}
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

describe "GET /api/v1/tasks/:id" do
  let!(:my_task) { create(:task, project: project) }
  let!(:someone_elses_task) { create(:task) }

  context "with a valid JWT token" do
    context "when the task belongs to the user" do
      it "returns the task details successfully" do
        get "/api/v1/tasks/#{my_task.id}", headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(my_task.id)
        expect(json_response['title']).to eq(my_task.title)
        expect(json_response['description']).to eq(my_task.description)
        expect(json_response['status']).to eq(my_task.status)
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
describe "GET /api/v1/tasks/searchby/:title" do
  let!(:my_task) { create(:task, title: "Unique Assignment Title", description: "this the unique assignment title", project: project) }
  let!(:someone_elses_task) { create(:task, title: "Secret Assignment Title") }

  context "with a valid JWT token" do
    context "when the task belongs to the user" do
      it "returns the task details successfully" do
        get "/api/v1/tasks/searchby/#{ERB::Util.url_encode(my_task.title)}", headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(json_response.first['id']).to eq(my_task.id)
        expect(json_response.first['title']).to eq(my_task.title)
        expect(json_response.first['description']).to eq(my_task.description)
        expect(json_response.first['status']).to eq(my_task.status)
        expect(json_response.first['priority']).to eq(my_task.priority)
      end
    end

    context "when the task belongs to a different user" do
      it "returns a 404 not found status" do
        get "/api/v1/tasks/searchby/rails", headers: valid_headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq("Task not found")
      end
    end

    context "when the task ID does not exist at all" do
      it "returns a 404 not found status" do
        get "/api/v1/tasks/nil", headers: valid_headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq("Task not found")
      end
    end
  end

  context "without a valid JWT token" do
    it "returns a 401 unauthorized status" do
      get "/api/v1/tasks/searchby/:title", headers: invalid_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

describe "PUT/PATCH /api/v1/tasks/:id" do
  let!(:my_task) { create(:task, project: project, creator: user) }
  let!(:someone_elses_task) { create(:task) }

let(:another_user) { create(:user) }
  let(:valid_update_params) do
    {
    task: {
    title: "Rails Updated Assignment",
    description: "blood bank management system",
    status: "todo",
    priority: "medium",
    due_date: "10/10/2026",
    assignee_id: another_user.id,
      project_id: project.id
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
describe "PUT/PATCH /api/v1/tasks" do
  let!(:user_tasks) { create_list(:task, 25, project: project) }
  let!(:other_task) { create(:task) }
  let(:params) { valid_params_ids }
end

describe "DELETE /api/v1/tasks/:id" do
  let!(:my_task) { create(:task, project: project,) }
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
