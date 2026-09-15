# spec/requests/admin/dashboard_spec.rb
require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  let(:admin_user) { create(:admin_user) }
  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  context "when authenticated as admin" do
    before do
      login_as(admin_user, scope: :admin_user)
    end

    describe "GET /admin/dashboard" do
      let!(:recent_user) { create(:user) }
      let!(:completed_task) { create(:task) }
      let!(:overdue_task) { create(:task, status: 0, title: "Fix Bug", due_date: 2.days.from_now) }

      it "renders the dashboard successfully with all metric panels" do
        get admin_dashboard_path

        expect(response).to have_http_status(:success)

        expect(response.body).to include("total user")
        expect(response.body).to include("total tasks")
        expect(response.body).to include("task status")
        expect(response.body).to include("overdue task")
      end

      it "displays the correct statistical counts" do
        get admin_dashboard_path

        expect(response.body).to include("1")
        expect(response.body).to include("2")
      end

      it "renders the Recent Users and Recent Tasks tables with correct data" do
        get admin_dashboard_path

        expect(response.body).to include("Jain")
        expect(response.body).to include(completed_task.title)
        expect(response.body).to include(overdue_task.title)
      end
    end
  end

  context "when unauthenticated" do
    describe "GET /admin/dashboard" do
      it "redirects the guest user to the admin login page" do
        get admin_dashboard_path
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
