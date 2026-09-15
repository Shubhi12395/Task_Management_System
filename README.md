# README

## ⚙️ Getting Started

### Prerequisites
* **Ruby** (v3.2.0 or higher)
* **Bundler** installed (`gem install bundler`)
* **PostgreSQL** (running locally)

### Setup Instructions
Follow these steps to get your local development environment running:

1. **Clone the repository:**
   ```bash
   git clone https://github.com
   cd Task_Management_System
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Set up the database:**
   ```bash
   rails db:create
   ```
   ```bash
   rails db:migrate
   ```
   ```bash
   rails db:seed
   ```

4. **Start the local server:**
   ```bash
   rails server
   ```
   The application will be accessible at `http://localhost:3000`.

---
## Environment Variables
Duplicate the `.env.example` file to create your own configuration file:

```bash
cp .env.example .env
```

Configure the following variables in your `.env` file:

| Variable | Description | Example Value |
| :--- | :--- | :--- |
| `DATABASE_URL` | Connection string for PostgreSQL | `postgres://localhost:5432/my_db` |
| `JWT_SECRET_KEY` | Secret key used to sign authentication tokens | `super_secret_token_key_123` |
| `API_DOMAIN` | Base URL of the API host | `http://localhost:3000` |

---
## 🚀 API Endpoint Reference
Below are the primary core endpoints. For interactive query testing, see the Interactive Documentation section below.

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/login` | Authenticate user and return JWT | **Yes** |
| `GET` | `/api/v1/users/me` | Retrieve the authenticated user's profile | **Yes** |
| `GET` | `/api/v1/projects` | List all user's projects with pagination | **Yes** |
| `POST` | `/api/v1/projects` | Create a new project | **Yes** |
| `GET` | `/api/v1/tasks` | List all user;s tasks | **Yes** |
| `POST` | `/api/v1/tasks` | Create a new task | **Yes** |

---
## 🔑 Authentication Flow
This API uses **JSON Web Tokens (JWT)** for secure authentication. 

1. **Log In:** Send a `POST` request to `/api/v1/auth/login` with your credentials.
2. **Receive Token:** The server validates credentials and returns a `jwt_token` in the JSON response payload.
3. **Authorize Requests:** Attach this token to the header of all protected requests:
   ```http
   Authorization: Bearer <your_jwt_token>
   ```

---
## 🧪 Test Commands
We write tests using RSpec to verify application logic and generate API documentation.

* **Run all tests:**
  ```bash
  bundle exec rspec
  ```
* **Run a specific test file:**
  ```bash
  bundle exec rspec spec/requests/api/v1/tasks_spec.rb
  ```
  