# Wumpus World DBMS: Technical Implementation Guide

**Project Team:** Milind Nevrekar and Team Members

This document serves as the complete technical guide for understanding how the Wumpus World Database Management System is built, its technology stack, and its internal implementation logic.

---

## 1. Technology Stack

The project relies on a modern, robust, and lightweight technology stack suitable for a Data Management System. 

### 1.1 Database (DBMS)
**PostgreSQL** was chosen as the relational database.
- **Why PostgreSQL?**: It is an open-source, enterprise-grade object-relational database system. It handles complex queries, large datasets, and strict data integrity constraints (like the `CHECK` constraints we use for Wumpus World logic) better than lighter alternatives like SQLite or MySQL.
- **Connection Adapter**: The backend connects to PostgreSQL using the `psycopg` (v3) binary adapter, which is highly efficient and designed specifically for Python.

### 1.2 Backend Framework
**Python 3** combined with **Flask** (v3.0).
- **Flask**: A lightweight WSGI web application framework. It provides the routing (`@app.route`), HTTP request handling, and server-side rendering logic.
- **Flask-SQLAlchemy**: An extension for Flask that adds support for SQLAlchemy. It provides a powerful Object-Relational Mapper (ORM) that maps Python classes to our PostgreSQL database tables.

### 1.3 Frontend
**Server-Side Rendering (SSR) via Jinja2 & Bootstrap**.
- **Jinja2**: Flask's built-in templating engine. It injects dynamic Python data (like database queries) straight into the HTML before sending it to the browser.
- **Bootstrap**: The frontend uses Bootstrap utility classes (`card`, `col-md-6`, `btn-primary`) to rapidly build a clean, responsive, and mobile-friendly user interface.
- **Vanilla JavaScript**: Used sparingly for dynamic frontend logic (such as making the `end_time` required dynamically based on the session status).

---

## 2. Project Architecture & Folder Structure

The project follows a standard **Model-View-Controller (MVC)** architectural pattern adapted for Flask (using Blueprints).

```text
MAIN_PROJECT/
├── schema.sql           # Raw SQL to build the PostgreSQL tables & constraints
├── seed_data.sql        # Raw SQL to populate the DB with initial test data
├── queries.sql          # Analytical SQL queries (Data Warehouse reporting)
└── backend/
    ├── app.py           # The application entry point (registers Blueprints)
    ├── database.py      # Database connection pooling and setup
    ├── models.py        # SQLAlchemy ORM classes (User, Agent, World, GameSession)
    ├── routes/          # The Controllers (Logic for handling HTTP requests)
    │   ├── agents.py
    │   ├── game_sessions.py
    │   ├── simulation.py
    │   ├── users.py
    │   └── worlds.py
    └── templates/       # The Views (HTML + Jinja2)
        ├── base.html    # Base layout (Navbar, footer, CSS imports)
        ├── index.html   # Dashboard homepage
        └── game_sessions/
            ├── list.html
            └── form.html # Handles create/edit UI
```

---

## 3. Database Implementation Details

The PostgreSQL database is heavily normalized to avoid data redundancy. 

### Key Tables
1. **Users**: Stores the players/researchers. Primary Key: `user_id`.
2. **Agents**: Stores the specific AI algorithms being tested.
3. **Worlds**: Stores metadata about a specific 4x4 cave layout.
4. **Game Sessions**: The core transactional table. Links a User, Agent, and World together via Foreign Keys.
5. **Game Steps**: A high-volume table tracking every single move the agent makes (Forward, Turn, Shoot) and its coordinates.
6. **Step Perceptions**: A junction table linking exactly what percepts (Stench, Breeze) were felt during a specific Game Step.

### Enforcing Rules via Constraints
To maintain strict data integrity, the DBMS uses native SQL `CHECK` constraints. For example, the `result` column in `game_sessions` is strictly locked:
```sql
ALTER TABLE game_sessions ADD CONSTRAINT chk_game_sessions_result 
CHECK (result IN ('Won', 'Died (Fell in Pit)', 'Died (Eaten by Wumpus)', 'Escaped Without Gold', 'Incomplete'));
```
If the backend attempts to save an invalid result, PostgreSQL blocks the transaction and prevents database corruption. This enforces AI business logic at the lowest possible data layer.

---

## 4. Backend Logic Implementation (Game Sessions)

The most complex part of the backend implementation resides in `routes/game_sessions.py`.

### 4.1 Automated Generation Engine
When a user clicks "Create Session", they only provide the `World`, `Agent`, and `Player`. The backend uses a custom Python generation engine to simulate the rest.

**Weighted Probability Setup:**
The `status` of the session is chosen using `random.choices` with custom weights to ensure interesting game variances.
```python
# 10% Running, 40% Completed, 40% Failed, 10% Abandoned
data["status"] = random.choices(STATUSES, weights=[10, 40, 40, 10], k=1)[0]
```

**Outcome Constraints:**
The system forces logical consistency:
- If the status is `Failed`, the outcome is forced to be a death (`Died (Fell in Pit)` or `Died (Eaten by Wumpus)`). 
- If the status is `Completed`, the outcome is forced to be `Won` or `Escaped Without Gold`.
- If the status is `Running` or `Abandoned`, the outcome is forced to be `Incomplete`.

**Wumpus World Scoring Rules (Implemented):**
The Final Score is calculated algorithmically inside the backend before saving to the DB:
1. `Base Score`: Win (+1000), Die (-1000), Escape/Incomplete (0).
2. `Step Penalty`: Generates a random number of steps (5 to 300) and subtracts `1` point for each step.
3. `Arrow Penalty`: Randomly decides if the arrow was shot and subtracts `10` points if true.

```python
data["final_score"] = base_score - data["total_steps"] - (arrows_shot * 10)
```

By abstracting this logic to the backend controller, the frontend remains extremely lightweight, and the Database solely receives sanitized, logically valid data.
