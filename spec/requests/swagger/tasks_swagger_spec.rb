require 'swagger_helper'

RSpec.describe 'Tasks API Documentation', type: :request, swagger: true do
  let(:user_record) { create(:user) }
  let(:project) { create(:project, user: user_record) }
  let(:token) { JsonWebToken.encode(user_id: user_record.id) }
  let(:Authorization) { "Bearer #{token}" }
  before do
    user_record.update!(refresh_token: token)
  end
  path '/api/v1/tasks' do
    post 'Creates a task' do
      tags 'Tasks'
      security [ Bearer: {} ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :task_data, in: :body, schema: {
      type: :object,
      properties: {
      task: {
      type: :object,
      properties: {
      title: { type: :string, example: 'New Automated Task' },
      description: { type: :string, example: 'Setting up test specs' },
      status: { type: :string, example: 'todo' },
      priority: { type: :string, example: 'medium' },
      due_date: { type: :string, example: '10/10/2026' },
      project_id: { type: :integer, example: 1 },
      assignee_id: { type: :integer, example: 2 }
    },
    required: [ 'title', 'project_id' ]
  }
},
required: [ 'task' ]
}

response '201', 'Task created successfully' do
  let(:task_data) { { task: { title: 'New Automated Task', project_id: 1 } } }
  it 'documents success' do |example|
    submit_request(example.metadata)
  end
end

response '401', 'unauthorized status' do
  let(:Authorization) { 'Bearer invalid_token' }
  let(:task_data) { { task: { title: 'New Automated Task', project_id: 1 } } }
  it 'documents unauthorized' do |example|
    submit_request(example.metadata)
  end
end

response '422', 'unprocessable entity error' do
  let(:task_data) { { task: { title: '', project_id: 1 } } }
  it 'documents validation failure' do |example|
    submit_request(example.metadata)
  end
end
end

get 'Lists and paginates all tasks' do
  tags 'Tasks'
  security [ Bearer: {} ]
  produces 'application/json'

  response '200', 'Success with Pagy metadata framework' do
    it 'documents standard list indexing' do |example|
      submit_request(example.metadata)
    end
  end
end
end
path '/api/v1/tasks/sortby/{sort}' do
  parameter name: :sort, in: :path, type: :string, description: 'Sort criteria (e.g., priority, due_date)'

  get 'Lists tasks sorted by a specific parameter field attribute' do
    tags 'Tasks'
    security [ Bearer: {} ]
    produces 'application/json'

    response '200', 'Success with Pagy metadata framework sorted output' do
      let(:sort) { 'priority' }
      it 'documents sorted list access' do |example|
        submit_request(example.metadata)
      end
    end
  end
end
path '/api/v1/tasks/{id}' do
  parameter name: :id, in: :path, type: :integer, description: 'Task ID'

  get 'Retrieves details of a specific task' do
    tags 'Tasks'
    security [ Bearer: {} ]
    produces 'application/json'

    response '200', 'returns the task details successfully' do
      let(:id) { 1 }
      it 'documents successfully showing task' do |example|
        submit_request(example.metadata)
      end
    end

    response '401', 'unauthorized status' do
      let(:Authorization) { 'Bearer invalid_token' }
      let(:id) { 1 }
      it 'documents unauthorized access' do |example|
        submit_request(example.metadata)
      end
    end

    response '404', 'Task not found' do
      let(:id) { 999999 }
      it 'documents task not found' do |example|
        submit_request(example.metadata)
      end
    end
  end

  patch 'Updates an existing task' do
    tags 'Tasks'
    security [ Bearer: {} ]
    consumes 'application/json'
    produces 'application/json'

    parameter name: :task_update_data, in: :body, schema: {
    type: :object,
    properties: {
    task: {
    type: :object,
    properties: {
    title: { type: :string, example: 'Rails Updated Assignment' },
    description: { type: :string, example: 'blood bank management system' },
    status: { type: :string, example: 'todo' },
    priority: { type: :string, example: 'medium' },
    due_date: { type: :string, example: '10/10/2026' },
    assignee_id: { type: :integer, example: 2 },
    project_id: { type: :integer, example: 1 }
  }
}
},
required: [ 'task' ]
}

response '200', 'Task updated successfully' do
  let(:id) { 1 }
  let(:task_update_data) { { task: { title: 'Rails Updated Assignment' } } }
  it 'documents valid task updates' do |example|
    submit_request(example.metadata)
  end
end

response '404', 'Task not found' do
  let(:id) { 999999 }
  let(:task_update_data) { { task: { title: 'Rails Updated Assignment' } } }
  it 'documents task missing for update' do |example|
    submit_request(example.metadata)
  end
end

response '422', 'unprocessable entity status' do
  let(:id) { 1 }
  let(:task_update_data) { { task: { title: '' } } }
  it 'documents validation updates failure' do |example|
    submit_request(example.metadata)
  end
end
end
end

path '/api/v1/tasks/searchby/{title}' do
  parameter name: :title, in: :path, type: :string, description: 'The title (or partial title) to search for'

  get 'Searches and retrieves task details matching a given title' do
    tags 'Tasks'
    security [ Bearer: {} ]
    produces 'application/json'

    response '200', 'returns matching task records list successfully' do
      let(:title) { CGI.escape("Unique Assignment Title") }
      it 'documents a successful search query' do |example|
        submit_request(example.metadata)
      end
    end

    response '401', 'unauthorized status' do
      let(:Authorization) { 'Bearer invalid_token' }
      let(:title) { 'any-title' }
      it 'documents unauthorized search attempt' do |example|
        submit_request(example.metadata)
      end
    end

    response '404', 'Task not found match scenario' do
      let(:title) { 'nonexistent-title-query-string' }
      it 'documents search query yields no matches' do |example|
        submit_request(example.metadata)
      end
    end
  end
end

let!(:user_tasks) { create_list(:task, 25, project: project) }
let!(:other_task) { create(:task) }

path '/api/v1/tasks/{id}' do
  delete 'Deletes a specific task' do
    tags 'Tasks'
    security [ Bearer: [] ]
    produces 'application/json'
    parameter name: :id, in: :path, type: :string, description: 'Task ID'

    response '200', 'Task deleted successfully' do
      let(:my_task) { create(:task, project: project) }
      let(:id) { my_task.id }

      run_test! do |response|
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task deleted successfully')
        expect(json_response['task']['id']).to eq(my_task.id)
        expect(Task.exists?(my_task.id)).to be_falsey
      end
    end

    response '404', 'Task not found' do
      context 'when the task belongs to a different user' do
        let(:someone_elses_task) { create(:task) }
        let(:id) { someone_elses_task.id }
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq("Task not found")
        end
      end

      context 'when the task ID does not exist at all' do
        let(:id) { '999999' }
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq("Task not found")
        end
      end
    end

    response '401', 'Unauthorized' do
      let(:my_task) { create(:task, project: project) }
      let(:id) { my_task.id }

      context 'with an invalid JWT token' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end

      context 'with missing auth headers' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end

path '/api/v1/tasks' do
  delete 'Bulk deletes selected tasks' do
    tags 'Tasks'
    security [ Bearer: [] ]
    consumes 'application/json'
    produces 'application/json'
    parameter name: :body, in: :body, schema: {
    type: :object,
    properties: {
    ids: { type: :array, items: { type: :integer }, description: 'Array of task IDs to delete' }
  },
  required: [ 'ids' ]
}

response '200', 'Tasks deleted successfully' do
  let(:task1) { create(:task, project: project, creator: user_record) }
  let(:task2) { create(:task, project: project, creator: user_record) }
  let(:body) { { ids: [ task1.id, task2.id ] } }

  run_test! do |response|
    expect(JSON.parse(response.body)["message"]).to eq("Tasks deleted successfully")
  end
end
end
end

path '/api/v1/tasks/duetoday' do
  get 'Retrieves tasks due today' do
    tags 'Tasks'
    security [ Bearer: [] ]
    produces 'application/json'

    response '200', 'Serialized tasks due today with pagy metadata' do
      before do
        task_due_today = create(:task1, project: project, creator: user_record)
        allow(user_record.tasks).to receive_message_chain(:duetoday, :includes).and_return([ task_due_today ])
      end

      run_test! do |response|
        json = JSON.parse(response.body)
        expect(json["tasks"]).to be_an(Array)
        expect(json["meta"]).to be_present
      end
    end

    response '404', 'No tasks due today' do
      before do
        allow(user_record.tasks).to receive_message_chain(:duetoday, :includes).and_return([])
      end

      run_test! do |response|
        expect(JSON.parse(response.body)["error"]).to eq("No tasks due today")
      end
    end
  end
end

path '/api/v1/tasks/overdue' do
  get 'Retrieves overdue tasks' do
    tags 'Tasks'
    security [ Bearer: [] ]
    produces 'application/json'

    response '200', 'Serialized overdue tasks with pagy metadata' do
      before do
        overdue_task = create(:task2, :skip_validate, project: project, creator: user_record)
        allow(user_record.tasks).to receive_message_chain(:overdue, :includes).and_return([ overdue_task ])
      end

      run_test! do |response|
        json = JSON.parse(response.body)
        expect(json["tasks"]).to be_an(Array)
      end
    end

    call_overdue_404 = response '404', 'No overdue tasks' do
      before do
        allow(user_record.tasks).to receive_message_chain(:overdue, :includes).and_return([])
      end

      run_test! do |response|
        expect(JSON.parse(response.body)["error"]).to eq("No overdue tasks")
      end
    end
  end
end

path '/api/v1/tasks/pending' do
  get 'Retrieves pending tasks' do
    tags 'Tasks'
    security [ Bearer: [] ]
    produces 'application/json'

    response '200', 'Serialized pending tasks with pagy metadata' do
      before do
        pending_task = create(:task, project: project, creator: user_record)
        allow(user_record.tasks).to receive_message_chain(:pending, :includes).and_return([ pending_task ])
      end

      run_test! do |response|
        json = JSON.parse(response.body)
        expect(json["tasks"]).to be_an(Array)
      end
    end

    response '404', 'No pending tasks' do
      let(:user) { create(:user) }
      let(:token) { JsonWebToken.encode(user_id: user.id) }
      let(:Authorization) { "Bearer #{token}" }

      before do
         user.update!(refresh_token: token)
        allow(user.tasks).to receive_message_chain(:pending, :includes).and_return([])
      end

      run_test! do |response|
        json_response = JSON.parse(response.body)
        expect(JSON.parse(response.body)["error"]).to eq("No pending tasks")
      end
    end
  end
end

path '/api/v1/tasks/by_priority' do
  get 'Retrieves tasks ordered by priority' do
    tags 'Tasks'
    security [ Bearer: [] ]
    produces 'application/json'

    response '200', 'Serialized priority tasks with pagy metadata' do
      before do
        priority_task = create(:task, project: project, creator: user_record)
        allow(user_record.tasks).to receive_message_chain(:by_priority, :includes).and_return([ priority_task ])
      end

      run_test! do |response|
        json = JSON.parse(response.body)
        expect(json["tasks"]).to be_an(Array)
      end
    end

    response '404', 'No tasks with valid priority' do
      let(:user) { create(:user) }
      let(:token) { JsonWebToken.encode(user_id: user.id) }
      let(:Authorization) { "Bearer #{token}" }

      before do
        user.update!(refresh_token: token)

        allow_any_instance_of(User).to receive_message_chain(:tasks, :by_priority, :includes).and_return(Task.none)
      end
      run_test! do |response|
        expect(JSON.parse(response.body)["error"]).to eq("No tasks with valid priority")
      end
    end
  end
end
end
