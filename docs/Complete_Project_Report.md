# WUMPUS WORLD DATABASE MANAGEMENT SYSTEM
## Comprehensive Project Report & Implementation Guide

**Project Team Members:**
- Milind Nevrekar
- [Add Group Member 2 Name Here]
- [Add Group Member 3 Name Here]
- [Add Group Member 4 Name Here]

---

## 1. ABSTRACT
The "Wumpus World" is a classic problem in Artificial Intelligence used to demonstrate knowledge-based agents, logical reasoning, and inference in partially observable environments. As the complexity of simulating this environment grows, there is a critical need for a robust system to record, track, and analyze agent behaviors over thousands of iterations. 

This project entails the design and implementation of a complete Database Management System (DBMS) that stores operational data for Wumpus World game sessions. Built using a modern technology stack (PostgreSQL, Python, Flask, and Bootstrap), the system empowers researchers and players to monitor performance, analyze decision-making efficiency, and mathematically compare various AI agents using strict logical constraints and scoring rules.

---

## 2. INTRODUCTION

### 2.1 Background
Traditional Wumpus World implementations focus entirely on the AI logic (the agent's brain), executing a run and immediately discarding the data. However, analyzing long-term performance, comparing different AI algorithms, and finding statistical patterns in how agents die requires a robust operational database. This project bridges the gap between AI theory and Database Data Engineering.

### 2.2 Scope of the Project
The system manages:
- **Users**: Humans observing or initiating the sessions.
- **Agents**: The AI algorithms or distinct entities making decisions.
- **Worlds**: The dynamically generated 4x4 grid caves containing pits, the Wumpus, and gold.
- **Game Sessions**: The overarching metadata of an agent attempting a world.
- **Game Steps**: A chronological, highly granular step-by-step history of every single move, perception, and score change within a session.

### 2.3 Purpose
To provide a full-stack web application tailored exclusively to recording Wumpus World game sessions, enforcing strict AI logic at the database level, and providing a foundation for a Data Warehouse to run complex analytical queries on AI performance.

---

## 3. SYSTEM ANALYSIS

### 3.1 Problem Statement
Machine learning models and logical agents require massive amounts of historical data to evaluate their efficiency. Without a structured database, data regarding agent performance, common hazards, and optimal paths is lost. The problem is to design a highly normalized relational database and an accompanying web interface that can rapidly ingest, validate, and store simulation data.

### 3.2 Proposed System
A web-based DBMS where users can create entities (Worlds, Agents, Players) and generate "Game Sessions". The backend will act as a simulation engine, calculating outcomes based on strict probabilities and mathematical scoring models before persisting the data to a PostgreSQL database.

### 3.3 Functional Requirements
- **CRUD Operations**: Users must be able to Create, Read, Update, and Delete Worlds, Agents, and Game Sessions.
- **Automated Generation**: The system must be able to automatically simulate game outcomes, causes of death, and steps.
- **Rule Enforcement**: The system must block invalid data (e.g., an agent cannot 'Win' if it died, or have an 'End Time' if the session is 'Running').

### 3.4 Non-Functional Requirements
- **Scalability**: The database must handle potentially millions of `game_steps` efficiently.
- **Data Integrity**: The database must use constraints to prevent orphaned records or logical impossibilities.
- **User Interface**: The UI must be responsive, modern, and accessible on mobile and desktop.

---

## 4. WUMPUS WORLD DOMAIN (THE RULES)

The Wumpus World is a **4×4 grid** (16 total rooms) where the agent starts at `(1,1)`. The agent's goal is to find the gold, pick it up, and return safely to the starting square to climb out of the cave.

### 4.1 Environment & Hazards
- **Wumpus**: A dangerous monster that occupies one room. If the agent enters its room, the agent dies. It can be killed with a single arrow.
- **Pits**: Deep holes. If the agent enters a pit, it immediately dies. There can be multiple pits.

### 4.2 Agent Percepts
The agent cannot see hazards directly. It senses them via clues:
- **Stench**: The Wumpus is in an adjacent (Up/Down/Left/Right) cell.
- **Breeze**: A Pit is in an adjacent cell.
- **Glitter**: The Gold is in the current cell.
- **Bump**: The agent hit a wall.
- **Scream**: The Wumpus has been killed.

### 4.3 Standard Performance Measure (Scoring Logic)
The system calculates scores automatically based on the official metrics:
- **Find Gold and Exit**: `+1000` Points
- **Die**: `-1000` Points
- **Every Action/Step**: `-1` Point
- **Shoot Arrow**: `-10` Points

---

## 5. SYSTEM DESIGN & ARCHITECTURE

### 5.1 Technology Stack
- **Database (DBMS)**: PostgreSQL (via `psycopg` v3 binary adapter). Chosen for its enterprise-grade handling of massive datasets and strict SQL `CHECK` constraints.
- **Backend Framework**: Python 3 with Flask. Provides WSGI routing and HTTP handling.
- **ORM**: Flask-SQLAlchemy. Maps Python objects to SQL tables, preventing SQL injection and simplifying CRUD.
- **Frontend**: HTML5, CSS3, Bootstrap 5 (for rapid responsive UI), Jinja2 (for Server-Side Rendering), and Vanilla JavaScript (for dynamic form validation).

### 5.2 System Architecture (MVC Pattern)
The project is modularized using the **Model-View-Controller (MVC)** architectural pattern, specifically adapted for Flask using Blueprints.

#### Directory Structure
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

#### Data Flow & Processing
1. **Client Request**: The user interacts with the UI (e.g., clicking "Create Session").
2. **Controller (Routes)**: A Flask Blueprint (e.g., `game_sessions.py`) intercepts the HTTP POST request. It validates the data and mathematically generates the missing AI variables (like step count and outcome) using the Simulation Engine.
3. **Model (SQLAlchemy)**: The Controller passes the sanitized data to the Model classes defined in `models.py`.
4. **Database (PostgreSQL)**: SQLAlchemy translates the Python models into SQL `INSERT` statements, which the PostgreSQL database validates against its strict `CHECK` constraints.
5. **View (Jinja2)**: Upon success, the Controller fetches updated records and passes them to the Jinja2 View templates to render HTML dynamically back to the user.

### 5.3 Database Entity-Relationship Design
The PostgreSQL database is heavily normalized (3NF) to avoid data anomaly.
1. **users**: Primary Key: `user_id`.
2. **agents**: AI metadata.
3. **worlds**: Configuration of the grid.
4. **game_sessions**: Ties User, Agent, and World.
5. **game_steps**: Tracks every single move the agent makes. Foreign Key to `game_sessions`.
6. **step_perceptions**: Junction table linking percepts (Stench/Breeze) to specific Game Steps.

---

## 6. IMPLEMENTATION DETAILS

### 6.1 Database Constraints
To maintain strict data integrity, the DBMS uses native SQL `CHECK` constraints. This ensures business logic is enforced at the lowest layer.
```sql
ALTER TABLE game_sessions ADD CONSTRAINT chk_game_sessions_result 
CHECK (result IN ('Won', 'Died (Fell in Pit)', 'Died (Eaten by Wumpus)', 'Escaped Without Gold', 'Incomplete'));
```

### 6.2 The Simulation Engine (Game Session Generation)
When a user generates a new session, the backend (`routes/game_sessions.py`) intercepts the request and calculates the simulation mathematically.

**1. Weighted Probabilities:**
The session `status` is selected using statistical weights to ensure realistic distribution:
```python
# 10% Running, 40% Completed, 40% Failed, 10% Abandoned
data["status"] = random.choices(STATUSES, weights=[10, 40, 40, 10], k=1)[0]
```

**2. Logical Death Classification:**
If the agent fails, the backend enforces a logical death reason:
```python
if data["status"] == "Failed":
    data["result"] = random.choice(["Died (Fell in Pit)", "Died (Eaten by Wumpus)"])
```

**3. Automated Score Calculation:**
The `final_score` applies the strict Wumpus World Performance rules mathematically:
```python
data["final_score"] = base_score - data["total_steps"] - (arrows_shot * 10)
```

### 6.3 Frontend Dynamic Logic
To improve User Experience (UX), Vanilla JavaScript is used to dynamically alter HTML form constraints. For example, if a session's status is changed to "Completed", the JavaScript instantly adds the `required` attribute to the `end_time` input, forcing the user to supply a date before submitting.

---

## 7. ANALYTICS & DATA WAREHOUSE

With the database populated, the system supports complex analytical SQL queries. Examples include:
- **Best AI Agents**: Grouping by `agent_id` and calculating the `AVG(final_score)` to mathematically prove which AI algorithm performs best.
- **Lethal Worlds**: Analyzing which `world_id` results in the highest percentage of "Died (Fell in Pit)" results.
- **Score Progression**: Using Window Functions (`LAG`) to track how an agent's score dynamically rises and falls over a single session.

---

## 8. CONCLUSION & FUTURE SCOPE

The Wumpus World Database Management System successfully acts as an intersection between Artificial Intelligence, Software Engineering, and Database Architecture. 

**Future Enhancements:**
- Integrating a real Python-based AI agent to play the game live and stream the `game_steps` directly into the database in real-time.
- Implementing a visual 2D grid playback tool on the frontend to watch historical `game_sessions` unfold step-by-step using the stored database records.
- Creating a separate Data Warehouse (OLAP) schema tailored strictly for complex aggregations.
