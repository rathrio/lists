# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lists is a self-hosted application for tracking movies, TV shows, games, books, and other items. The application consists of:

- **API**: Ruby on Rails backend (`api/`) with PostgreSQL and Redis
- **UI**: React frontend (`ui/`) with TypeScript, MobX state management, and Vite
- **iOS**: Native iOS app (`ios/`) using Swift and SwiftUI

The main goal is that we collaborate on the ios app.

## Development Commands

### API (Rails Backend) - `cd api`

```bash
# Start services
brew services start postgresql@14
brew services start redis

# Server
./bin/rails server

# Database
./bin/rails db:setup
./bin/rails db:migrate

# Tests
./bin/rails test

# Linting
rubocop
```

### UI (React Frontend) - `cd ui`

```bash
# Development server
npm run dev

# Build
npm run build

# Tests
npm run test
npm run test:ui

# Install dependencies
npm install
```

### Deployment

Top-level scripts for production deployment:
- `./deploy` - Builds and deploys backend and frontend to lists.rathr.io
- `./redis` - Redis CLI in container
- `./postgres` - PostgreSQL shell in container
- `./web` - Shell in web container

## Architecture

### Backend (Rails API)

**Models:**
- `Item` - Core entity (movies, books, games, etc.) with status tracking (todo/doing/done), ratings, and soft delete
- `List` - Categories for organizing items
- `User` - Authentication via Clearance gem
- `Tag` - For categorizing items
- `Link` - External URLs associated with items

**Key Features:**
- Paranoia gem for soft deletes
- CarrierWave + MiniMagick for image uploads
- JWT authentication
- Background jobs with Solid Queue
- Metadata scraping from external APIs (TMDB, IGDB, Google Books, Edamam)

**Controllers:**
- RESTful API with nested routes: `/lists/:id/items`
- Special endpoints: `/items/archived`, item actions like `toggle_status`, `scrape`, `restore`

### Frontend (React + MobX)

**Store Architecture:**
- `RootStore` - Central store container
- `ItemStore` - Item management and API calls
- `ListStore` - List management
- `SessionStore` - Authentication state
- `NavStore` - Navigation state
- `NotificationStore` - User notifications

**Component Structure:**
- `App.tsx` - Root component with auth routing
- `layout/` - Navigation, notifications, main sections
- `items/` - Item-related components
- `login/` - Authentication components
- `settings/` - Configuration components
- `elements/` - Reusable UI elements

**Styling:**
- Bulma CSS framework
- SCSS for custom styles
- FontAwesome icons

### External APIs

The application integrates with several APIs for metadata scraping:
- **Movies/TV**: The Movie DB (TMDB)
- **Games**: IGDB
- **Books**: Google Books API
- **Recipes**: Edamam API

## Development Notes

- Rails app runs on default port 3000
- React app runs on port 3001 (configured in package.json)
- Uses modern Rails 8.0 with Solid Queue for background jobs
- MobX stores are exposed to window.store for debugging
- Soft delete pattern used throughout with Paranoia gem
- Image handling via CarrierWave with ImageMagick processing
