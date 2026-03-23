# Restaurant Menu Management API

A RESTful API built with Ruby on Rails (API‑only mode) for managing restaurants and their menu items. It includes JWT authentication, full‑text search with Elasticsearch (via Searchkick), and robust error handling.

---

## 🚀 Features

- **User authentication** – JWT tokens with secure password storage.
- **Role‑based access** – `super_admin` and `admin_restaurant` roles.
- **CRUD operations** for `Restaurant`, `MenuItem`, and `Category`.
- **Pagination** – using Kaminari (customizable limit).
- **Full‑text search** – on restaurant name/address and menu item name (via Elasticsearch).
- **Filtering** – menu items by category, restaurants by name/address.
- **Seed data** – sample users, categories, restaurants, and menu items.
- **Docker support** – one‑command local environment with PostgreSQL, Elasticsearch, and Redis.
- **Testing** – comprehensive Minitest suite for controllers and models.

---

## 🛠 Tech Stack

| Component          | Technology                                      |
|--------------------|-------------------------------------------------|
| Backend            | Ruby on Rails 8.1.2 (API‑only mode)            |
| Database           | PostgreSQL 14                                   |
| Search             | Elasticsearch 8.x + Searchkick                  |
| Authentication     | JWT (JSON Web Tokens)                           |
| Pagination         | Kaminari                                        |
| Background Jobs    | Sidekiq (optional, Redis)                       |
| Testing            | Minitest                                        |
| Containerization   | Docker, Docker Compose                          |
| API Documentation  | Swagger (planned, using swagger-blocks)        |

---

## 📋 Prerequisites

Make sure you have the following installed on your local machine:

- Ruby 4.0.2 (use `rbenv` or `rvm`)
- PostgreSQL 14
- Elasticsearch 8.x
- Redis (optional, for Sidekiq)
- Bundler (`gem install bundler`)

If you prefer to use Docker, you only need **Docker Desktop** (with WSL2 integration on Windows) or Docker Engine.

---

## 🔧 Local Setup (without Docker)

### 1. Clone the repository
```bash
git clone git@github.com:taufiktop/restaurant-api.git
cd restaurant-api
```

### 2. Install Ruby dependencies
```bash
bundle install
```

### 3. Configure the database
Edit `config/database.yml` to match your PostgreSQL credentials. For a typical development setup, you can use:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 10 } %>

development:
  <<: *default
  host: localhost
  username: postgres
  password: postgres
  port: 5432
  database: restaurant_dev

test:
  <<: *default
  host: localhost
  username: postgres
  password: postgres
  port: 5432
  database: restaurant_test

production:
  <<: *default
  database: restaurant_prod
  # Override with environment variables in production
```
**Note:** Change `username` and `password` if your PostgreSQL user is different.

### 4. Create the database
```bash
rails db:create
```

### 5. Run migrations and seed data
```bash
rails db:migrate
rails db:seed
```

### 6. Set up Elasticsearch
Start Elasticsearch if it's not already running. On Ubuntu:
```bash
sudo systemctl start elasticsearch
# Verify
curl http://localhost:9200
```
Reindex all models to populate the Elasticsearch indices:
```
rails searchkick:reindex:all
```
This will create the necessary indices and fill them with your existing records.

### 7. Start the Rails server
```bash
rails s
```
The API will be available at http://localhost:3000.


## 🧪 Testing
The project uses **Minitest** with integration tests. Before running tests, prepare the test database:

```bash
rails db:create db:migrate RAILS_ENV=test
rails searchkick:reindex:all RAILS_ENV=test  # optional, ensures search tests work
```

Then run the entire test suite:

```bash
rails test
```
To run a specific test file:

```bash
rails test test/controllers/restaurants_controller_test.rb
```

## 📦 Environment Variables
The application uses environment variables for configuration. You can set them in your shell or use a `.env` file (with the `dotenv-rails` gem).

| Variable           | Description                           | Default
|--------------------|---------------------------------------|----------------------------|
| DATABASE_HOST      | PostgreSQL host                       | localhost                  |
| DATABASE_USERNAME  | PostgreSQL user                       | postgres                   |
| DATABASE_PASSWORD  | PostgreSQL password                   | (empty)                    |
| ELASTICSEARCH_URL  | Elasticsearch URL                     | http://localhost:9200      |
| REDIS_URL          | edis URL (for Sidekiq)                | redis://localhost:6379/0   |
| JWT_SECRET Jobs    | Secret key for JWT signing (512-bit)  | required                   |

**JWT Secret** – generate a 512‑bit secret (e.g., `openssl rand -base64 364`) and store it in Rails credentials:

```bash
EDITOR=vim rails credentials:edit
```

Add the following:
```yaml
jwt:
  secret_key: "/4M3AUgj3oUAAMQvRS0XyfJlU4shkF6aT8Lykp9vR5I="
  subject: "resto-app"
  algorithm: HS512
  issuer: "menu-management"
  expiration: 24.hours.to_i
```
Save and exit.

## 📡 API Endpoints Overview

All endpoints (except `/users/signin`) require an **Authorization header** with a valid JWT token.

### 1. Authentication

| Method | Endpoint        | Description                     |
|--------|-----------------|---------------------------------|
| POST   | `/users/signin` | Sign in with email/password. Returns a JWT token. |

**Request body:**
```json
{
  "email": "superadmin@resto.com",
  "password": "password123"
}
```
**Response body:**
```json
{
  "status": 200,
  "message": "User signed in successfully",
  "data": {
    "id": "...",
    "email": "superadmin@resto.com",
    "name": "Super Admin",
    "role": "super_admin",
    "access_token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

### 2. Restaurants
| Method | Endpoint             | Description                                   |
|--------|----------------------|-----------------------------------------------|
| GET    | `/restaurants`       | List restaurants (paginated, searchable)      |
| GET    | `/restaurants/:id`   | Get restaurant details (includes menu items)  |
| POST   | `/restaurants`       | Create a new restaurant                       |
| PUT    | `/restaurants/:id`   | Update a restaurant                           |
| DELETE | `/restaurants/:id`   | Delete a restaurant                           |

Search / Pagination parameters (for `GET /restaurants`):
- `page` (default: 1)
- `limit` (default: 12, max: 50)
- `search` – search by name or address (word_middle matching)

Request example (POST):
```json
{
  "restaurant": {
    "name": "Spicy Garden",
    "address": "123 Sukhumvit Rd, Bangkok",
    "phone": "+6621234567",
    "opening_hours": "10:00",
    "closing_hours": "22:00"
  }
}
```

### 3. Menu Items
| Method | Endpoint                                   | Description                                              |
|--------|--------------------------------------------|----------------------------------------------------------|
| GET    | `/restaurants/:restaurant_id/menu_items`   | List menu items for a restaurant (filter by category_id) |
| POST   | `/restaurants/:restaurant_id/menu_items`   | Add a new menu item                                      |
| PUT    | `/menu_items/:id`                          | Update a menu item                                       |
| DELETE | `/menu_items/:id`                          | Delete a menu item                                       |

Filter / Search parameters (for `GET /restaurants/:restaurant_id/menu_items`):
- category_id (UUID) – filter by category
- search – full‑text search on name


## 🧠 Design Decisions
- API‑only mode – light and fast, no views or assets.

- JWT authentication – stateless, suitable for APIs.

- Searchkick – simple Elasticsearch integration with ActiveRecord.

- UUID primary keys – avoid predictable IDs and support future sharding.

- Database constraints – foreign keys with dependent: :destroy where appropriate.

- Pagination – Kaminari with a maximum limit of 50 to prevent overload.

- Testing – Minitest integration tests covering all endpoints and edge cases.


## 🚀 Deployment
For production, you can deploy to platforms like Render, Railway, or Fly.io. Remember to:

- Set environment variables (especially `JWT_SECRET`, database credentials).

- Run migrations (`rails db:migrate`) and seed (if needed).

- Reindex Elasticsearch (`rails searchkick:reindex:all`).


## ❓ Troubleshooting
### `searchkick` errors on test/development
If you see `Bad mapping - run Restaurant.reindex`, ensure Elasticsearch is running and you've run the reindex command for the appropriate environment.

### PostgreSQL connection refused
Make sure PostgreSQL is running (`sudo systemctl status postgresql`) and the credentials in `database.yml` are correct.

### JWT decode errors
Check that the `JWT_SECRET` in credentials is set and matches the one used during token generation.


## 📄 License
This project is created for the HungryHub take‑home assignment. It is not licensed for redistribution.


## 🙌 Acknowledgements
- Ruby on Rails community

- Searchkick (ankane)

- JWT gem

- All open‑source contributors