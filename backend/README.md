# Wumpus World Flask Backend

This backend connects to the PostgreSQL schema created for the Wumpus World Database Management System.
It includes a Bootstrap 5 server-rendered frontend integrated with Flask routes.

## Setup

1. Create and seed the PostgreSQL database:

```bash
createdb wumpus_world_dbms
psql -d wumpus_world_dbms -f ../schema.sql
psql -d wumpus_world_dbms -f ../seed_data.sql
```

2. Create a virtual environment and install dependencies:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. Configure the database connection.

Copy `backend/.env.example` to `backend/.env` and update the values if needed:

```bash
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/wumpus_world_dbms
SECRET_KEY=change-this-secret
```

4. Run the Flask app:

```bash
flask --app app run --debug
```

Open:

```text
http://127.0.0.1:5000
```

## Features

- Dashboard with PostgreSQL summary counts
- User CRUD
- World CRUD
- Agent CRUD
- Game session CRUD
- Game history page with step-by-step action, cell, score, and perception data
- Bootstrap 5 navigation bar, sidebar, cards, tables, and forms
- Responsive layout
- JavaScript table search and delete confirmations
- Input validation
- Database error handling
- Server-rendered HTML pages
