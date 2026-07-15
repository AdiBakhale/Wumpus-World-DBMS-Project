# Running the Backend (quick guide)

This document explains two ways to run the Flask backend:

- Full (recommended): Run against PostgreSQL using the provided schema and seed files.
- Quick (developer): Run locally with SQLite for fast testing (no Postgres required).

---

## Prerequisites

- Python 3.10+ / 3.11 recommended
- `git` and a terminal

For the full Postgres setup also install:
- PostgreSQL server (local or remote)
- `psql` client (for applying the schema and seed files)

---

## Option A — Full Postgres (recommended)

1. Create the database and apply schema + seed (run from repository root):

```bash
createdb wumpus_world_dbms
psql -d wumpus_world_dbms -f schema.sql
psql -d wumpus_world_dbms -f seed_data.sql
```

2. Create and activate a virtual environment, then install dependencies:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. Create a `.env` file in `backend/` (copy `.env.example` if present) and set:

```text
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/wumpus_world_dbms
SECRET_KEY=change-this-secret
```

4. Run the app:

```bash
# From backend/
python app.py
```

Open: http://127.0.0.1:5001

---

## Option B — Quick local SQLite (no Postgres)

This is useful for quick local testing. The project will auto-create tables when using SQLite.

1. Create and activate a virtual environment and install minimal packages:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
# minimal deps for quick run (avoids installing psycopg)
pip install Flask==3.0.3 Flask-SQLAlchemy==3.1.1 python-dotenv==1.0.1
```

2. Create a `backend/.env` file with:

```text
DATABASE_URL=sqlite:///wumpus_local.db
SECRET_KEY=dev-secret
```

3. Run the app (it will auto-create tables in `wumpus_local.db`):

```bash
python app.py
```

Open: http://127.0.0.1:5001

---

## Notes and troubleshooting

- If you prefer to use the full `requirements.txt` even for quick runs, install it instead of the minimal set; note that `psycopg[binary]` requires a C build environment or binary wheels.
- The `schema.sql` and `seed_data.sql` are PostgreSQL-targeted and may not work on SQLite.
- If using Postgres remotely, update `DATABASE_URL` accordingly.
- To reset the SQLite quick DB, delete `backend/wumpus_local.db` and restart the app.

If you want, I can try to run the quick SQLite flow here now. Let me know to proceed.
