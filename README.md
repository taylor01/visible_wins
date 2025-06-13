# Visible Wins

A modern Ruby on Rails application for IT team schedule tracking and management. Visible Wins enables teams to track work locations, availability, and schedules with a focus on visibility and coordination.

![Rails Version](https://img.shields.io/badge/Rails-8.0.2-red.svg)
![Ruby Version](https://img.shields.io/badge/Ruby-3.1+-red.svg)
![Tests](https://img.shields.io/badge/Tests-Passing-green.svg)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

Visible Wins is designed for organizations that need to track and coordinate team schedules effectively. Whether your team works from office, home, or travels frequently, Visible Wins provides a centralized platform to:

- **Track weekly schedules** across multiple teams
- **Plan resource allocation** with visibility into team availability
- **Coordinate meetings** by viewing team member locations
- **Manage hybrid work arrangements** with clear status indicators

## ✨ Features

### 🔐 Authentication & Security
- **Single Sign-On (SSO)** via OIDC/Okta integration
- **Automatic user provisioning** from corporate directory
- **Role-based access control** (Executive, Director, Manager, Staff)
- **Secure session management** with automatic cleanup

### 📅 Schedule Management
- **Weekly schedule tracking** with 6 status options:
  - 🏢 **Office** - Working from office
  - 🏠 **WFH** - Working from home
  - 🏖️ **Vacation** - On vacation
  - 📴 **OOO** - Out of office
  - ❓ **TBD** - To be determined
  - ✈️ **Travel** - Business travel
- **Smart week navigation** with Thursday logic (defaults to next week after Thursday)
- **Multi-week view** for planning and historical reference
- **Real-time updates** with immediate visual feedback

### 👥 Team Organization
- **Hierarchical team structure** with parent-child relationships
- **Team filtering** for focused schedule views
- **Manager hierarchy** for organizational visibility
- **Automatic team assignment** based on directory data

### ⚙️ Administration
- **User management** with full CRUD operations
- **Team management** and hierarchy configuration
- **Role assignment** and privilege management
- **Admin dashboard** with key metrics

### 📱 User Experience
- **Responsive design** optimized for mobile and desktop
- **Progressive Web App** capabilities
- **Accessible interface** with ARIA support
- **Intuitive navigation** with breadcrumbs and clear actions

## 🛠 Technology Stack

### Backend
- **Ruby on Rails 8.0.2** - Modern Rails with solid adapters
- **SQLite3** - Database with Rails 8 solid cache/queue/cable
- **Puma** - High-performance web server
- **OmniAuth + OpenID Connect** - Enterprise authentication

### Frontend
- **Tailwind CSS** - Utility-first CSS framework
- **Stimulus** - Lightweight JavaScript framework
- **Turbo** - SPA-like navigation
- **Import Maps** - Modern JavaScript module management

### Development & Testing
- **Minitest** - Rails testing framework
- **Capybara + Selenium** - System testing
- **Faker** - Test data generation
- **Parallel testing** - Faster test execution

### DevOps
- **Docker** - Containerization
- **Kamal** - Modern Rails deployment
- **Thruster** - Performance optimization

## 📋 Prerequisites

- **Ruby 3.1 or higher**
- **Node.js 18 or higher**
- **SQLite3**
- **Git**
- **OIDC Provider** (Okta, Azure AD, etc.)

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/visible_wins.git
cd visible_wins
```

### 2. Install Dependencies
```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
npm install
```

### 3. Database Setup
```bash
# Create and migrate database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 4. Build Assets
```bash
# Compile Tailwind CSS and other assets
bin/rails assets:precompile
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the root directory:

```bash
# OIDC Configuration (Required)
OKTA_ISSUER_URL=https://your-company.okta.com/oauth2/default
OKTA_CLIENT_ID=your_client_id
OKTA_CLIENT_SECRET=your_client_secret

# Application Configuration
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_base

# Database Configuration (Optional)
DATABASE_URL=sqlite3:db/development.sqlite3
```

### OIDC Provider Setup

1. **Create an OIDC Application** in your identity provider
2. **Configure redirect URIs**:
   - Development: `http://localhost:3000/auth/openid_connect/callback`
   - Production: `https://your-domain.com/auth/openid_connect/callback`
3. **Set required scopes**: `openid profile email groups`
4. **Configure group claims** for team assignment

### Database Configuration

The application uses SQLite3 by default with Rails 8 solid adapters:
- **Solid Cache** - For application caching
- **Solid Queue** - For background job processing
- **Solid Cable** - For WebSocket connections

## 🎮 Usage

### Starting the Application

```bash
# Development server
bin/rails server

# With specific port
bin/rails server -p 4000

# Background job processing
bin/rails solid_queue:start
```

### First Time Setup

1. **Access the application** at `http://localhost:3000`
2. **Sign in via SSO** - You'll be redirected to your OIDC provider
3. **Complete your profile** if additional information is needed
4. **Set your schedule** using the "Update My Schedule" button

### Admin Tasks

Admins can access additional features via the Admin menu:

```bash
# Grant admin privileges to a user (via Rails console)
bin/rails console
user = User.find_by(email: "admin@company.com")
user.update(admin: true)
```

## 📚 API Documentation

### Schedule API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | View team schedules |
| `GET` | `/schedules/:user_id/edit` | Edit user schedule |
| `PATCH` | `/schedules/:user_id` | Update user schedule |

### Admin API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/admin/users` | List all users |
| `POST` | `/admin/users` | Create new user |
| `GET` | `/admin/teams` | Manage teams |

## 🧪 Testing

### Running Tests

```bash
# Run all tests
bin/rails test

# Run specific test files
bin/rails test test/models/user_test.rb
bin/rails test test/controllers/schedules_controller_test.rb

# Run system tests
bin/rails test:system

# Test with coverage
bin/rails test
```

### Test Structure

- **Model Tests** - Validations, associations, and business logic
- **Controller Tests** - HTTP endpoints and authentication
- **Integration Tests** - Complete user workflows
- **System Tests** - Browser-based testing with Capybara

## 🚀 Deployment

### Using Kamal (Recommended)

```bash
# Setup deployment configuration
bin/kamal setup

# Deploy to production
bin/kamal deploy
```

### Using Docker

```bash
# Build production image
docker build -t visible_wins .

# Run with environment variables
docker run -p 3000:3000 --env-file .env visible_wins
```

### Environment Setup

Ensure production environment variables are configured:

```bash
# Required for production
RAILS_ENV=production
SECRET_KEY_BASE=production_secret_key
OKTA_ISSUER_URL=https://company.okta.com/oauth2/default
OKTA_CLIENT_ID=production_client_id
OKTA_CLIENT_SECRET=production_client_secret
```

## 🔮 Upcoming Features

### Phase 1 - Enhanced Scheduling
- [ ] **Recurring schedule templates** - Set patterns for multiple weeks
- [ ] **Schedule approval workflow** - Manager approval for time off
- [ ] **Calendar integration** - Sync with Outlook/Google Calendar
- [ ] **Mobile app** - Native iOS/Android applications

### Phase 2 - Analytics & Reporting
- [ ] **Team utilization reports** - Track office vs remote ratios
- [ ] **Capacity planning** - Resource allocation insights
- [ ] **Historical analytics** - Trends and patterns
- [ ] **Export capabilities** - CSV, PDF reports

### Phase 3 - Advanced Features
- [ ] **Desk booking integration** - Reserve office space
- [ ] **Meeting room coordination** - Availability based on schedules
- [ ] **Slack/Teams integration** - Bot for quick status updates
- [ ] **API endpoints** - Third-party integrations

### Phase 4 - Enterprise Features
- [ ] **Multi-tenant support** - Multiple organizations
- [ ] **Advanced role management** - Custom permission sets
- [ ] **Audit logging** - Complete change tracking
- [ ] **GDPR compliance** - Data privacy controls

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Write tests** for your changes
4. **Ensure tests pass** (`bin/rails test`)
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Code Style

- Follow Rails conventions and best practices
- Use Rubocop for style enforcement: `bundle exec rubocop`
- Run security checks: `bundle exec brakeman`
- Maintain test coverage above 90%

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/your-org/visible_wins/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-org/visible_wins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/visible_wins/discussions)

---

**Built with ❤️ by the IT Team**