require 'swagger_helper'

RSpec.describe 'API V1 Projects', type: :request do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:Authorization) { "Bearer #{token}" }
    before do
    user.update!(refresh_token: token)
  end
    path '/api/v1/projects' do
        get 'Retrieves all projects belonging to the current user' do
            tags 'Projects'
            security [ Bearer: [] ]
            produces 'application/json'

            response '200', 'Projects retrieved successfully' do
                schema type: :object,
                properties: {
                projects: { type: :array, items: { type: :object } },
                meta: { type: :object }
            },
            required: [ 'projects', 'meta' ]

            before do
                create_list(:project, 2, user: user)
                allow_any_instance_of(ApiController).to receive(:current_user).and_return(user)
            end

            run_test! do |response|
                json = JSON.parse(response.body)
                expect(json['projects']).to be_an(Array)
                expect(json['meta']).to be_present
            end
        end
    end

    post 'Creates a new project' do
        tags 'Projects'
        security [ Bearer: [] ]
        consumes 'application/json'
        produces 'application/json'
        parameter name: :project_payload, in: :body, schema: {
        type: :object,
        properties: {
        project: {
        type: :object,
        properties: {
        name: { type: :string, example: 'New API Design' },
        description: { type: :string, example: 'Build Rswag documentations' },
        status: { type: :string, example: 'pending' },
        due_date: { type: :string, format: 'date', example: '2026-12-31' }
    },
    required: [ 'name' ]
}
},
required: [ 'project' ]
}

response '201', 'Project created successfully' do
    let(:project_payload) { { project: { name: 'Valid Project Name', description: 'Context details' } } }

    run_test! do |response|
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Project created successfully')
        expect(json['project']).to be_present
    end
end

response '422', 'Unprocessable Entity (Validation failed)' do
    let(:project_payload) { { project: { name: '' } } }

    run_test! do |response|
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
    end
end
end
end

path '/api/v1/projects/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'Project ID'

    get 'Retrieves a specific project' do
        tags 'Projects'
        security [ Bearer: [] ]
        produces 'application/json'

        response '200', 'Project details retrieved' do
            let(:id) { project.id }

            run_test! do |response|
                json = JSON.parse(response.body)
                expect(json['id']).to eq(project.id)
            end
        end

        response '404', 'Project not found' do
            let(:id) { 'invalid_or_missing_id' }

            run_test! do |response|
                json = JSON.parse(response.body)
                expect(json['error']).to eq('Project not found')
            end
        end
    end

    patch 'Updates a specific project entirely' do
        tags 'Projects'
        security [ Bearer: [] ]
        consumes 'application/json'
        produces 'application/json'
        parameter name: :project_payload, in: :body, schema: {
        type: :object,
        properties: {
        project: {
        type: :object,
        properties: {
        name: { type: :string },
        description: { type: :string },
        status: { type: :string },
        due_date: { type: :string, format: 'date' }
    }
}
}
}

response '200', 'Project updated successfully' do
    let(:id) { project.id }
    let(:project_payload) { { project: { name: 'Updated Project Name', description: 'this the updated project' } } }

    run_test! do |response|
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Project updated successfully')
        expect(json['project']['name']).to eq('Updated Project Name')
    end
end

response '422', 'Validation failed during update' do
    let(:id) { project.id }
    let(:project_payload) { { project: { name: '' } } }

    run_test!
end

response '404', 'Project not found' do
    let(:id) { 'invalid_id' }
    let(:project_payload) { { project: { name: 'Testing' } } }

    run_test!
end
end

delete 'Deletes a specific project' do
    tags 'Projects'
    security [ Bearer: [] ]
    produces 'application/json'

    response '200', 'Project deleted successfully' do
        let(:id) { project.id }

        run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['message']).to eq('Project deleted successfully')
            expect(Project.exists?(project.id)).to be_falsey
        end
    end

    response '404', 'Project not found' do
        let(:id) { 'invalid_id' }

        run_test!
    end
end
end
end
