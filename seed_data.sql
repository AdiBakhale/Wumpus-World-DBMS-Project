-- Wumpus World Database Management System
-- PostgreSQL sample seed data
-- This script inserts realistic sample data for the approved operational schema.

BEGIN;

-- ============================================================================
-- Users
-- ============================================================================
INSERT INTO users (
    user_id, full_name, email, password_hash, created_at, is_active
) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Dr. Ananya Rao', 'ananya.rao@ji.edu', '$2b$12$samplehashananyarao', '2026-06-01 09:00:00+05:30', TRUE),
    (2, 'Prof. Vikram Mehta', 'vikram.mehta@ji.edu', '$2b$12$samplehashvikrammehta', '2026-06-01 09:10:00+05:30', TRUE),
    (3, 'Riya Sharma', 'riya.sharma@student.ji.edu', '$2b$12$samplehashriyasharma', '2026-06-02 10:15:00+05:30', TRUE),
    (4, 'Arjun Iyer', 'arjun.iyer@student.ji.edu', '$2b$12$samplehasharjuniyer', '2026-06-02 10:20:00+05:30', TRUE),
    (5, 'Meera Nair', 'meera.nair@student.ji.edu', '$2b$12$samplehashmeeranair', '2026-06-03 11:00:00+05:30', TRUE);


-- ============================================================================
-- Roles
-- ============================================================================
INSERT INTO roles (
    role_id, role_name, description
) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Admin', 'Can manage users, worlds, agents, and system reference data.'),
    (2, 'Instructor', 'Can create worlds, agents, simulations, and review results.'),
    (3, 'Student', 'Can run game sessions and view own results.'),
    (4, 'Viewer', 'Can view simulations and reports without modifying data.');


-- ============================================================================
-- User Roles
-- ============================================================================
INSERT INTO user_roles (
    user_role_id, user_id, role_id
) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 1),
    (2, 1, 2),
    (3, 2, 2),
    (4, 3, 3),
    (5, 4, 3),
    (6, 5, 3),
    (7, 5, 4);


-- ============================================================================
-- Worlds
-- ============================================================================
INSERT INTO worlds (
    world_id, created_by, world_name, description, grid_rows, grid_columns,
    difficulty_level, created_at, is_active
) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 'Training Cave', 'Easy 4x4 world with a small number of hazards for basic exploration.', 4, 4, 'Easy', '2026-06-05 09:00:00+05:30', TRUE),
    (2, 2, 'Inference Cave', 'Medium 4x4 world designed to test breeze and stench reasoning.', 4, 4, 'Medium', '2026-06-06 09:30:00+05:30', TRUE),
    (3, 1, 'Expert Cave', 'Hard 4x4 world with dense hazards and a risky gold location.', 4, 4, 'Hard', '2026-06-07 10:00:00+05:30', TRUE);


-- ============================================================================
-- Cells
-- Each world has a complete 4x4 grid. Cell IDs are row-major by world.
-- ============================================================================
INSERT INTO cells (
    cell_id, world_id, row_number, column_number, is_start_cell
) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 1, 1, TRUE),
    (2, 1, 1, 2, FALSE),
    (3, 1, 1, 3, FALSE),
    (4, 1, 1, 4, FALSE),
    (5, 1, 2, 1, FALSE),
    (6, 1, 2, 2, FALSE),
    (7, 1, 2, 3, FALSE),
    (8, 1, 2, 4, FALSE),
    (9, 1, 3, 1, FALSE),
    (10, 1, 3, 2, FALSE),
    (11, 1, 3, 3, FALSE),
    (12, 1, 3, 4, FALSE),
    (13, 1, 4, 1, FALSE),
    (14, 1, 4, 2, FALSE),
    (15, 1, 4, 3, FALSE),
    (16, 1, 4, 4, FALSE),

    (17, 2, 1, 1, TRUE),
    (18, 2, 1, 2, FALSE),
    (19, 2, 1, 3, FALSE),
    (20, 2, 1, 4, FALSE),
    (21, 2, 2, 1, FALSE),
    (22, 2, 2, 2, FALSE),
    (23, 2, 2, 3, FALSE),
    (24, 2, 2, 4, FALSE),
    (25, 2, 3, 1, FALSE),
    (26, 2, 3, 2, FALSE),
    (27, 2, 3, 3, FALSE),
    (28, 2, 3, 4, FALSE),
    (29, 2, 4, 1, FALSE),
    (30, 2, 4, 2, FALSE),
    (31, 2, 4, 3, FALSE),
    (32, 2, 4, 4, FALSE),

    (33, 3, 1, 1, TRUE),
    (34, 3, 1, 2, FALSE),
    (35, 3, 1, 3, FALSE),
    (36, 3, 1, 4, FALSE),
    (37, 3, 2, 1, FALSE),
    (38, 3, 2, 2, FALSE),
    (39, 3, 2, 3, FALSE),
    (40, 3, 2, 4, FALSE),
    (41, 3, 3, 1, FALSE),
    (42, 3, 3, 2, FALSE),
    (43, 3, 3, 3, FALSE),
    (44, 3, 3, 4, FALSE),
    (45, 3, 4, 1, FALSE),
    (46, 3, 4, 2, FALSE),
    (47, 3, 4, 3, FALSE),
    (48, 3, 4, 4, FALSE);


-- ============================================================================
-- Hazard Types
-- ============================================================================
INSERT INTO hazard_types (
    hazard_type_id, hazard_name, description
) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Pit', 'A fatal pit. Adjacent cells produce Breeze.'),
    (2, 'Wumpus', 'A dangerous monster. Adjacent cells produce Stench.');


-- ============================================================================
-- Cell Hazards
-- ============================================================================
INSERT INTO cell_hazards (
    cell_hazard_id, cell_id, hazard_type_id, is_active
) OVERRIDING SYSTEM VALUE VALUES
    (1, 7, 1, TRUE),
    (2, 14, 1, TRUE),
    (3, 12, 2, TRUE),

    (4, 20, 1, TRUE),
    (5, 25, 1, TRUE),
    (6, 30, 1, TRUE),
    (7, 27, 2, TRUE),

    (8, 35, 1, TRUE),
    (9, 42, 1, TRUE),
    (10, 47, 1, TRUE),
    (11, 39, 2, TRUE),
    (12, 44, 2, TRUE);


-- ============================================================================
-- Object Types
-- ============================================================================
INSERT INTO object_types (
    object_type_id, object_name, description
) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Gold', 'Treasure that the agent must collect before escaping.'),
    (2, 'Exit', 'The cave exit, normally located at the start cell.');


-- ============================================================================
-- Cell Objects
-- ============================================================================
INSERT INTO cell_objects (
    cell_object_id, cell_id, object_type_id, is_collected, is_active
) OVERRIDING SYSTEM VALUE VALUES
    (1, 15, 1, FALSE, TRUE),
    (2, 1, 2, FALSE, TRUE),
    (3, 32, 1, FALSE, TRUE),
    (4, 17, 2, FALSE, TRUE),
    (5, 48, 1, FALSE, TRUE),
    (6, 33, 2, FALSE, TRUE);


-- ============================================================================
-- Agents
-- ============================================================================
INSERT INTO agents (
    agent_id, created_by, agent_name, agent_type, strategy_description,
    created_at, is_active
) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 'Logic Explorer', 'Logic-Based', 'Uses percept history to infer safe cells before moving.', '2026-06-08 09:00:00+05:30', TRUE),
    (2, 2, 'Random Walker', 'Random', 'Chooses valid actions randomly without long-term planning.', '2026-06-08 09:15:00+05:30', TRUE),
    (3, 1, 'Rule Scout', 'Rule-Based', 'Follows hand-written rules for avoiding known risks and returning to exit.', '2026-06-08 09:30:00+05:30', TRUE);


-- ============================================================================
-- Action Types
-- ============================================================================
INSERT INTO action_types (
    action_type_id, action_name, description
) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Move Forward', 'Move one cell in the current direction.'),
    (2, 'Turn Left', 'Rotate the agent 90 degrees to the left.'),
    (3, 'Turn Right', 'Rotate the agent 90 degrees to the right.'),
    (4, 'Shoot', 'Fire the arrow in the current direction.'),
    (5, 'Grab', 'Pick up gold from the current cell.'),
    (6, 'Climb', 'Exit the cave from the start cell.'),
    (7, 'Wait', 'Remain in the current cell for one turn.');


-- ============================================================================
-- Perception Types
-- ============================================================================
INSERT INTO perception_types (
    perception_type_id, perception_name, description
) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Breeze', 'Sensed in cells adjacent to a pit.'),
    (2, 'Stench', 'Sensed in cells adjacent to a living Wumpus.'),
    (3, 'Glitter', 'Sensed when gold is present in the current cell.'),
    (4, 'Bump', 'Sensed when the agent attempts to move outside the grid.'),
    (5, 'Scream', 'Sensed after the Wumpus is killed by an arrow.');


-- ============================================================================
-- Game Sessions
-- ============================================================================
INSERT INTO game_sessions (
    session_id, world_id, agent_id, played_by, start_time, end_time, status,
    result, final_score, total_steps, gold_collected, agent_survived
) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, 1, 3, '2026-06-10 10:00:00+05:30', '2026-06-10 10:16:00+05:30', 'Completed', 'Won', 984, 16, TRUE, TRUE),
    (2, 1, 2, 4, '2026-06-10 11:00:00+05:30', '2026-06-10 11:15:00+05:30', 'Failed', 'Died', -1015, 15, FALSE, FALSE),
    (3, 2, 1, 5, '2026-06-11 10:00:00+05:30', '2026-06-11 10:18:00+05:30', 'Completed', 'Won', 982, 18, TRUE, TRUE),
    (4, 2, 3, 3, '2026-06-11 12:00:00+05:30', '2026-06-11 12:16:00+05:30', 'Completed', 'Escaped Without Gold', -16, 16, FALSE, TRUE),
    (5, 3, 2, 4, '2026-06-12 09:30:00+05:30', '2026-06-12 09:47:00+05:30', 'Failed', 'Died', -1017, 17, FALSE, FALSE);


-- ============================================================================
-- Game Steps
-- ============================================================================
INSERT INTO game_steps (
    step_id, session_id, step_number, cell_id, action_type_id,
    direction_facing, action_successful, score_after_step, step_time
) OVERRIDING SYSTEM VALUE VALUES
    -- Session 1: Logic Explorer wins in the easy world.
    (1, 1, 1, 1, 7, 'East', TRUE, -1, '2026-06-10 10:01:00+05:30'),
    (2, 1, 2, 2, 1, 'East', TRUE, -2, '2026-06-10 10:02:00+05:30'),
    (3, 1, 3, 2, 3, 'South', TRUE, -3, '2026-06-10 10:03:00+05:30'),
    (4, 1, 4, 6, 1, 'South', TRUE, -4, '2026-06-10 10:04:00+05:30'),
    (5, 1, 5, 10, 1, 'South', TRUE, -5, '2026-06-10 10:05:00+05:30'),
    (6, 1, 6, 10, 2, 'East', TRUE, -6, '2026-06-10 10:06:00+05:30'),
    (7, 1, 7, 11, 1, 'East', TRUE, -7, '2026-06-10 10:07:00+05:30'),
    (8, 1, 8, 11, 4, 'East', TRUE, -18, '2026-06-10 10:08:00+05:30'),
    (9, 1, 9, 15, 1, 'South', TRUE, -19, '2026-06-10 10:09:00+05:30'),
    (10, 1, 10, 15, 5, 'South', TRUE, 981, '2026-06-10 10:10:00+05:30'),
    (11, 1, 11, 11, 1, 'North', TRUE, 980, '2026-06-10 10:11:00+05:30'),
    (12, 1, 12, 10, 2, 'West', TRUE, 979, '2026-06-10 10:12:00+05:30'),
    (13, 1, 13, 6, 1, 'North', TRUE, 978, '2026-06-10 10:13:00+05:30'),
    (14, 1, 14, 2, 1, 'North', TRUE, 977, '2026-06-10 10:14:00+05:30'),
    (15, 1, 15, 1, 2, 'West', TRUE, 976, '2026-06-10 10:15:00+05:30'),
    (16, 1, 16, 1, 6, 'West', TRUE, 984, '2026-06-10 10:16:00+05:30'),

    -- Session 2: Random Walker dies in the easy world.
    (17, 2, 1, 1, 7, 'East', TRUE, -1, '2026-06-10 11:01:00+05:30'),
    (18, 2, 2, 2, 1, 'East', TRUE, -2, '2026-06-10 11:02:00+05:30'),
    (19, 2, 3, 3, 1, 'East', TRUE, -3, '2026-06-10 11:03:00+05:30'),
    (20, 2, 4, 3, 1, 'East', FALSE, -4, '2026-06-10 11:04:00+05:30'),
    (21, 2, 5, 3, 3, 'South', TRUE, -5, '2026-06-10 11:05:00+05:30'),
    (22, 2, 6, 7, 1, 'South', TRUE, -1006, '2026-06-10 11:06:00+05:30'),
    (23, 2, 7, 7, 7, 'South', TRUE, -1007, '2026-06-10 11:07:00+05:30'),
    (24, 2, 8, 7, 2, 'East', TRUE, -1008, '2026-06-10 11:08:00+05:30'),
    (25, 2, 9, 8, 1, 'East', TRUE, -1009, '2026-06-10 11:09:00+05:30'),
    (26, 2, 10, 8, 3, 'South', TRUE, -1010, '2026-06-10 11:10:00+05:30'),
    (27, 2, 11, 12, 1, 'South', TRUE, -1011, '2026-06-10 11:11:00+05:30'),
    (28, 2, 12, 12, 7, 'South', TRUE, -1012, '2026-06-10 11:12:00+05:30'),
    (29, 2, 13, 12, 2, 'East', TRUE, -1013, '2026-06-10 11:13:00+05:30'),
    (30, 2, 14, 16, 1, 'South', TRUE, -1014, '2026-06-10 11:14:00+05:30'),
    (31, 2, 15, 16, 7, 'South', TRUE, -1015, '2026-06-10 11:15:00+05:30'),

    -- Session 3: Logic Explorer wins in the medium world.
    (32, 3, 1, 17, 7, 'East', TRUE, -1, '2026-06-11 10:01:00+05:30'),
    (33, 3, 2, 18, 1, 'East', TRUE, -2, '2026-06-11 10:02:00+05:30'),
    (34, 3, 3, 19, 1, 'East', TRUE, -3, '2026-06-11 10:03:00+05:30'),
    (35, 3, 4, 19, 3, 'South', TRUE, -4, '2026-06-11 10:04:00+05:30'),
    (36, 3, 5, 23, 1, 'South', TRUE, -5, '2026-06-11 10:05:00+05:30'),
    (37, 3, 6, 23, 2, 'East', TRUE, -6, '2026-06-11 10:06:00+05:30'),
    (38, 3, 7, 24, 1, 'East', TRUE, -7, '2026-06-11 10:07:00+05:30'),
    (39, 3, 8, 24, 4, 'South', TRUE, -18, '2026-06-11 10:08:00+05:30'),
    (40, 3, 9, 28, 1, 'South', TRUE, -19, '2026-06-11 10:09:00+05:30'),
    (41, 3, 10, 32, 1, 'South', TRUE, -20, '2026-06-11 10:10:00+05:30'),
    (42, 3, 11, 32, 5, 'South', TRUE, 980, '2026-06-11 10:11:00+05:30'),
    (43, 3, 12, 28, 1, 'North', TRUE, 979, '2026-06-11 10:12:00+05:30'),
    (44, 3, 13, 24, 1, 'North', TRUE, 978, '2026-06-11 10:13:00+05:30'),
    (45, 3, 14, 23, 2, 'West', TRUE, 977, '2026-06-11 10:14:00+05:30'),
    (46, 3, 15, 22, 1, 'West', TRUE, 976, '2026-06-11 10:15:00+05:30'),
    (47, 3, 16, 21, 1, 'West', TRUE, 975, '2026-06-11 10:16:00+05:30'),
    (48, 3, 17, 17, 1, 'North', TRUE, 974, '2026-06-11 10:17:00+05:30'),
    (49, 3, 18, 17, 6, 'North', TRUE, 982, '2026-06-11 10:18:00+05:30'),

    -- Session 4: Rule Scout exits safely without collecting gold.
    (50, 4, 1, 17, 7, 'East', TRUE, -1, '2026-06-11 12:01:00+05:30'),
    (51, 4, 2, 18, 1, 'East', TRUE, -2, '2026-06-11 12:02:00+05:30'),
    (52, 4, 3, 19, 1, 'East', TRUE, -3, '2026-06-11 12:03:00+05:30'),
    (53, 4, 4, 19, 3, 'South', TRUE, -4, '2026-06-11 12:04:00+05:30'),
    (54, 4, 5, 23, 1, 'South', TRUE, -5, '2026-06-11 12:05:00+05:30'),
    (55, 4, 6, 23, 2, 'East', TRUE, -6, '2026-06-11 12:06:00+05:30'),
    (56, 4, 7, 24, 1, 'East', TRUE, -7, '2026-06-11 12:07:00+05:30'),
    (57, 4, 8, 24, 3, 'South', TRUE, -8, '2026-06-11 12:08:00+05:30'),
    (58, 4, 9, 24, 7, 'South', TRUE, -9, '2026-06-11 12:09:00+05:30'),
    (59, 4, 10, 23, 2, 'West', TRUE, -10, '2026-06-11 12:10:00+05:30'),
    (60, 4, 11, 22, 1, 'West', TRUE, -11, '2026-06-11 12:11:00+05:30'),
    (61, 4, 12, 21, 1, 'West', TRUE, -12, '2026-06-11 12:12:00+05:30'),
    (62, 4, 13, 17, 1, 'North', TRUE, -13, '2026-06-11 12:13:00+05:30'),
    (63, 4, 14, 17, 7, 'North', TRUE, -14, '2026-06-11 12:14:00+05:30'),
    (64, 4, 15, 17, 3, 'East', TRUE, -15, '2026-06-11 12:15:00+05:30'),
    (65, 4, 16, 17, 6, 'East', TRUE, -16, '2026-06-11 12:16:00+05:30'),

    -- Session 5: Random Walker dies in the hard world.
    (66, 5, 1, 33, 7, 'East', TRUE, -1, '2026-06-12 09:31:00+05:30'),
    (67, 5, 2, 34, 1, 'East', TRUE, -2, '2026-06-12 09:32:00+05:30'),
    (68, 5, 3, 35, 1, 'East', TRUE, -1003, '2026-06-12 09:33:00+05:30'),
    (69, 5, 4, 35, 7, 'East', TRUE, -1004, '2026-06-12 09:34:00+05:30'),
    (70, 5, 5, 35, 3, 'South', TRUE, -1005, '2026-06-12 09:35:00+05:30'),
    (71, 5, 6, 39, 1, 'South', TRUE, -1006, '2026-06-12 09:36:00+05:30'),
    (72, 5, 7, 39, 2, 'East', TRUE, -1007, '2026-06-12 09:37:00+05:30'),
    (73, 5, 8, 40, 1, 'East', TRUE, -1008, '2026-06-12 09:38:00+05:30'),
    (74, 5, 9, 40, 3, 'South', TRUE, -1009, '2026-06-12 09:39:00+05:30'),
    (75, 5, 10, 44, 1, 'South', TRUE, -1010, '2026-06-12 09:40:00+05:30'),
    (76, 5, 11, 44, 7, 'South', TRUE, -1011, '2026-06-12 09:41:00+05:30'),
    (77, 5, 12, 48, 1, 'South', TRUE, -1012, '2026-06-12 09:42:00+05:30'),
    (78, 5, 13, 48, 5, 'South', TRUE, -12, '2026-06-12 09:43:00+05:30'),
    (79, 5, 14, 47, 2, 'West', TRUE, -1014, '2026-06-12 09:44:00+05:30'),
    (80, 5, 15, 47, 7, 'West', TRUE, -1015, '2026-06-12 09:45:00+05:30'),
    (81, 5, 16, 46, 1, 'West', TRUE, -1016, '2026-06-12 09:46:00+05:30'),
    (82, 5, 17, 42, 1, 'North', TRUE, -1017, '2026-06-12 09:47:00+05:30');


-- ============================================================================
-- Step Perceptions
-- Perceptions are attached only to steps where the current cell produces a signal.
-- ============================================================================
INSERT INTO step_perceptions (
    step_perception_id, step_id, perception_type_id
) OVERRIDING SYSTEM VALUE VALUES
    -- Session 1
    (1, 4, 1),
    (2, 7, 1),
    (3, 7, 2),
    (4, 8, 1),
    (5, 8, 2),
    (6, 8, 5),
    (7, 9, 1),
    (8, 9, 3),
    (9, 10, 3),
    (10, 11, 1),
    (11, 11, 2),
    (12, 13, 1),

    -- Session 2
    (13, 19, 1),
    (14, 20, 4),
    (15, 22, 1),
    (16, 25, 2),
    (17, 27, 2),
    (18, 30, 2),

    -- Session 3
    (19, 34, 1),
    (20, 36, 2),
    (21, 38, 1),
    (22, 39, 1),
    (23, 39, 5),
    (24, 41, 3),
    (25, 42, 3),
    (26, 43, 1),
    (27, 44, 1),
    (28, 45, 2),
    (29, 48, 1),

    -- Session 4
    (30, 52, 1),
    (31, 54, 2),
    (32, 56, 1),
    (33, 57, 1),
    (34, 58, 1),
    (35, 59, 2),
    (36, 61, 1),

    -- Session 5
    (37, 67, 1),
    (38, 68, 1),
    (39, 71, 1),
    (40, 71, 2),
    (41, 73, 2),
    (42, 75, 2),
    (43, 77, 2),
    (44, 77, 3),
    (45, 78, 2),
    (46, 78, 3),
    (47, 79, 1),
    (48, 81, 1),
    (49, 82, 1);


-- ============================================================================
-- Reset identity sequences after explicit seed IDs.
-- ============================================================================
SELECT setval(pg_get_serial_sequence('users', 'user_id'), (SELECT max(user_id) FROM users));
SELECT setval(pg_get_serial_sequence('roles', 'role_id'), (SELECT max(role_id) FROM roles));
SELECT setval(pg_get_serial_sequence('user_roles', 'user_role_id'), (SELECT max(user_role_id) FROM user_roles));
SELECT setval(pg_get_serial_sequence('worlds', 'world_id'), (SELECT max(world_id) FROM worlds));
SELECT setval(pg_get_serial_sequence('cells', 'cell_id'), (SELECT max(cell_id) FROM cells));
SELECT setval(pg_get_serial_sequence('hazard_types', 'hazard_type_id'), (SELECT max(hazard_type_id) FROM hazard_types));
SELECT setval(pg_get_serial_sequence('cell_hazards', 'cell_hazard_id'), (SELECT max(cell_hazard_id) FROM cell_hazards));
SELECT setval(pg_get_serial_sequence('object_types', 'object_type_id'), (SELECT max(object_type_id) FROM object_types));
SELECT setval(pg_get_serial_sequence('cell_objects', 'cell_object_id'), (SELECT max(cell_object_id) FROM cell_objects));
SELECT setval(pg_get_serial_sequence('agents', 'agent_id'), (SELECT max(agent_id) FROM agents));
SELECT setval(pg_get_serial_sequence('action_types', 'action_type_id'), (SELECT max(action_type_id) FROM action_types));
SELECT setval(pg_get_serial_sequence('perception_types', 'perception_type_id'), (SELECT max(perception_type_id) FROM perception_types));
SELECT setval(pg_get_serial_sequence('game_sessions', 'session_id'), (SELECT max(session_id) FROM game_sessions));
SELECT setval(pg_get_serial_sequence('game_steps', 'step_id'), (SELECT max(step_id) FROM game_steps));
SELECT setval(pg_get_serial_sequence('step_perceptions', 'step_perception_id'), (SELECT max(step_perception_id) FROM step_perceptions));

COMMIT;
