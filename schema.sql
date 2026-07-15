-- Wumpus World Database Management System
-- PostgreSQL operational schema
-- This script creates the normalized 3NF schema for users, worlds, cells,
-- hazards, objects, agents, game sessions, actions, steps, and perceptions.

-- ============================================================================
-- Table: users
-- Purpose: Stores application users who create worlds, agents, and game sessions.
-- ============================================================================
CREATE TABLE users (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_full_name_not_blank CHECK (length(trim(full_name)) > 0),
    CONSTRAINT chk_users_email_format CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    CONSTRAINT chk_users_password_hash_not_blank CHECK (length(trim(password_hash)) > 0)
);

-- Case-insensitive email lookup and duplicate protection.
CREATE UNIQUE INDEX idx_users_email_lower ON users (lower(email));


-- ============================================================================
-- Table: roles
-- Purpose: Stores user role names such as Admin, Instructor, Student, and Viewer.
-- ============================================================================
CREATE TABLE roles (
    role_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    description TEXT,

    CONSTRAINT uq_roles_role_name UNIQUE (role_name),
    CONSTRAINT chk_roles_role_name_not_blank CHECK (length(trim(role_name)) > 0)
);


-- ============================================================================
-- Table: user_roles
-- Purpose: Resolves the many-to-many relationship between users and roles.
-- ============================================================================
CREATE TABLE user_roles (
    user_role_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,

    CONSTRAINT uq_user_roles_user_role UNIQUE (user_id, role_id),
    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles (role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_user_roles_user_id ON user_roles (user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles (role_id);


-- ============================================================================
-- Table: worlds
-- Purpose: Stores reusable Wumpus World map definitions and grid dimensions.
-- ============================================================================
CREATE TABLE worlds (
    world_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by INTEGER NOT NULL,
    world_name VARCHAR(100) NOT NULL,
    description TEXT,
    grid_rows INTEGER NOT NULL,
    grid_columns INTEGER NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL DEFAULT 'Custom',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_worlds_created_by_name UNIQUE (created_by, world_name),
    CONSTRAINT chk_worlds_name_not_blank CHECK (length(trim(world_name)) > 0),
    CONSTRAINT chk_worlds_grid_rows CHECK (grid_rows BETWEEN 2 AND 50),
    CONSTRAINT chk_worlds_grid_columns CHECK (grid_columns BETWEEN 2 AND 50),
    CONSTRAINT chk_worlds_difficulty_level
        CHECK (difficulty_level IN ('Easy', 'Medium', 'Hard', 'Custom')),
    CONSTRAINT fk_worlds_created_by
        FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_worlds_created_by ON worlds (created_by);
CREATE INDEX idx_worlds_difficulty_level ON worlds (difficulty_level);
CREATE INDEX idx_worlds_is_active ON worlds (is_active);


-- ============================================================================
-- Table: cells
-- Purpose: Stores every grid cell belonging to a world.
-- ============================================================================
CREATE TABLE cells (
    cell_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    world_id INTEGER NOT NULL,
    row_number INTEGER NOT NULL,
    column_number INTEGER NOT NULL,
    is_start_cell BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT uq_cells_world_position UNIQUE (world_id, row_number, column_number),
    CONSTRAINT chk_cells_row_number CHECK (row_number >= 1),
    CONSTRAINT chk_cells_column_number CHECK (column_number >= 1),
    CONSTRAINT fk_cells_world
        FOREIGN KEY (world_id)
        REFERENCES worlds (world_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE INDEX idx_cells_world_id ON cells (world_id);
CREATE INDEX idx_cells_position ON cells (world_id, row_number, column_number);

-- A world should have at most one start cell.
CREATE UNIQUE INDEX idx_cells_one_start_cell_per_world
    ON cells (world_id)
    WHERE is_start_cell = TRUE;


-- ============================================================================
-- Table: hazard_types
-- Purpose: Stores valid hazard categories such as Pit and Wumpus.
-- ============================================================================
CREATE TABLE hazard_types (
    hazard_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hazard_name VARCHAR(50) NOT NULL,
    description TEXT,

    CONSTRAINT uq_hazard_types_hazard_name UNIQUE (hazard_name),
    CONSTRAINT chk_hazard_types_name_not_blank CHECK (length(trim(hazard_name)) > 0)
);


-- ============================================================================
-- Table: cell_hazards
-- Purpose: Stores hazards placed in cells for a world configuration.
-- ============================================================================
CREATE TABLE cell_hazards (
    cell_hazard_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cell_id INTEGER NOT NULL,
    hazard_type_id INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_cell_hazards_cell_type UNIQUE (cell_id, hazard_type_id),
    CONSTRAINT fk_cell_hazards_cell
        FOREIGN KEY (cell_id)
        REFERENCES cells (cell_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_cell_hazards_hazard_type
        FOREIGN KEY (hazard_type_id)
        REFERENCES hazard_types (hazard_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_cell_hazards_cell_id ON cell_hazards (cell_id);
CREATE INDEX idx_cell_hazards_hazard_type_id ON cell_hazards (hazard_type_id);
CREATE INDEX idx_cell_hazards_active ON cell_hazards (is_active);


-- ============================================================================
-- Table: object_types
-- Purpose: Stores valid non-hazard object categories such as Gold and Exit.
-- ============================================================================
CREATE TABLE object_types (
    object_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    object_name VARCHAR(50) NOT NULL,
    description TEXT,

    CONSTRAINT uq_object_types_object_name UNIQUE (object_name),
    CONSTRAINT chk_object_types_name_not_blank CHECK (length(trim(object_name)) > 0)
);


-- ============================================================================
-- Table: cell_objects
-- Purpose: Stores non-hazard objects placed in cells, such as gold or exits.
-- ============================================================================
CREATE TABLE cell_objects (
    cell_object_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cell_id INTEGER NOT NULL,
    object_type_id INTEGER NOT NULL,
    is_collected BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_cell_objects_cell_type UNIQUE (cell_id, object_type_id),
    CONSTRAINT chk_cell_objects_collected_requires_inactive
        CHECK (is_collected = FALSE OR is_active = FALSE),
    CONSTRAINT fk_cell_objects_cell
        FOREIGN KEY (cell_id)
        REFERENCES cells (cell_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_cell_objects_object_type
        FOREIGN KEY (object_type_id)
        REFERENCES object_types (object_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_cell_objects_cell_id ON cell_objects (cell_id);
CREATE INDEX idx_cell_objects_object_type_id ON cell_objects (object_type_id);
CREATE INDEX idx_cell_objects_active ON cell_objects (is_active);


-- ============================================================================
-- Table: agents
-- Purpose: Stores agent profiles and the strategy used by each agent.
-- ============================================================================
CREATE TABLE agents (
    agent_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by INTEGER NOT NULL,
    agent_name VARCHAR(100) NOT NULL,
    agent_type VARCHAR(30) NOT NULL,
    strategy_description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_agents_created_by_name UNIQUE (created_by, agent_name),
    CONSTRAINT chk_agents_name_not_blank CHECK (length(trim(agent_name)) > 0),
    CONSTRAINT chk_agents_agent_type
        CHECK (agent_type IN ('Human', 'Random', 'Rule-Based', 'Logic-Based')),
    CONSTRAINT fk_agents_created_by
        FOREIGN KEY (created_by)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_agents_created_by ON agents (created_by);
CREATE INDEX idx_agents_agent_type ON agents (agent_type);
CREATE INDEX idx_agents_is_active ON agents (is_active);


-- ============================================================================
-- Table: game_sessions
-- Purpose: Stores one complete playthrough or simulation attempt.
-- ============================================================================
CREATE TABLE game_sessions (
    session_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    world_id INTEGER NOT NULL,
    agent_id INTEGER NOT NULL,
    played_by INTEGER NOT NULL,
    start_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'Running',
    result VARCHAR(30) NOT NULL DEFAULT 'Incomplete',
    final_score INTEGER NOT NULL DEFAULT 0,
    total_steps INTEGER NOT NULL DEFAULT 0,
    gold_collected BOOLEAN NOT NULL DEFAULT FALSE,
    agent_survived BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_game_sessions_status
        CHECK (status IN ('Running', 'Completed', 'Failed', 'Abandoned')),
    CONSTRAINT chk_game_sessions_result
        CHECK (result IN ('Won', 'Died', 'Escaped Without Gold', 'Incomplete')),
    CONSTRAINT chk_game_sessions_total_steps CHECK (total_steps >= 0),
    CONSTRAINT chk_game_sessions_end_after_start
        CHECK (end_time IS NULL OR end_time >= start_time),
    CONSTRAINT chk_game_sessions_completed_has_end_time
        CHECK (
            (status = 'Running' AND end_time IS NULL)
            OR (status <> 'Running' AND end_time IS NOT NULL)
        ),
    CONSTRAINT fk_game_sessions_world
        FOREIGN KEY (world_id)
        REFERENCES worlds (world_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_game_sessions_agent
        FOREIGN KEY (agent_id)
        REFERENCES agents (agent_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_game_sessions_played_by
        FOREIGN KEY (played_by)
        REFERENCES users (user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_game_sessions_world_id ON game_sessions (world_id);
CREATE INDEX idx_game_sessions_agent_id ON game_sessions (agent_id);
CREATE INDEX idx_game_sessions_played_by ON game_sessions (played_by);
CREATE INDEX idx_game_sessions_status ON game_sessions (status);
CREATE INDEX idx_game_sessions_result ON game_sessions (result);
CREATE INDEX idx_game_sessions_start_time ON game_sessions (start_time);


-- ============================================================================
-- Table: action_types
-- Purpose: Stores valid actions an agent can perform during a game step.
-- ============================================================================
CREATE TABLE action_types (
    action_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action_name VARCHAR(50) NOT NULL,
    description TEXT,

    CONSTRAINT uq_action_types_action_name UNIQUE (action_name),
    CONSTRAINT chk_action_types_name_not_blank CHECK (length(trim(action_name)) > 0)
);


-- ============================================================================
-- Table: game_steps
-- Purpose: Stores the ordered movement and decision history for each session.
-- ============================================================================
CREATE TABLE game_steps (
    step_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL,
    cell_id INTEGER NOT NULL,
    action_type_id INTEGER NOT NULL,
    direction_facing VARCHAR(10) NOT NULL,
    action_successful BOOLEAN NOT NULL DEFAULT TRUE,
    score_after_step INTEGER NOT NULL DEFAULT 0,
    step_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_game_steps_session_step UNIQUE (session_id, step_number),
    CONSTRAINT chk_game_steps_step_number CHECK (step_number >= 1),
    CONSTRAINT chk_game_steps_direction
        CHECK (direction_facing IN ('North', 'South', 'East', 'West')),
    CONSTRAINT fk_game_steps_session
        FOREIGN KEY (session_id)
        REFERENCES game_sessions (session_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_game_steps_cell
        FOREIGN KEY (cell_id)
        REFERENCES cells (cell_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_game_steps_action_type
        FOREIGN KEY (action_type_id)
        REFERENCES action_types (action_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_game_steps_session_id ON game_steps (session_id);
CREATE INDEX idx_game_steps_cell_id ON game_steps (cell_id);
CREATE INDEX idx_game_steps_action_type_id ON game_steps (action_type_id);
CREATE INDEX idx_game_steps_step_time ON game_steps (step_time);


-- ============================================================================
-- Table: perception_types
-- Purpose: Stores valid perceptions such as Breeze, Stench, Glitter, Bump, Scream.
-- ============================================================================
CREATE TABLE perception_types (
    perception_type_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    perception_name VARCHAR(50) NOT NULL,
    description TEXT,

    CONSTRAINT uq_perception_types_perception_name UNIQUE (perception_name),
    CONSTRAINT chk_perception_types_name_not_blank CHECK (length(trim(perception_name)) > 0)
);


-- ============================================================================
-- Table: step_perceptions
-- Purpose: Resolves the many-to-many relationship between game steps and perceptions.
-- ============================================================================
CREATE TABLE step_perceptions (
    step_perception_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    step_id INTEGER NOT NULL,
    perception_type_id INTEGER NOT NULL,

    CONSTRAINT uq_step_perceptions_step_type UNIQUE (step_id, perception_type_id),
    CONSTRAINT fk_step_perceptions_step
        FOREIGN KEY (step_id)
        REFERENCES game_steps (step_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_step_perceptions_perception_type
        FOREIGN KEY (perception_type_id)
        REFERENCES perception_types (perception_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE INDEX idx_step_perceptions_step_id ON step_perceptions (step_id);
CREATE INDEX idx_step_perceptions_perception_type_id ON step_perceptions (perception_type_id);
