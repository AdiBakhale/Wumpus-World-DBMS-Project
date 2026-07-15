-- Wumpus World Database Management System
-- Demonstration SQL queries for PostgreSQL
-- Run this file after schema.sql and seed_data.sql.

-- ============================================================================
-- 1. SELECT
-- Lists all active users in the system.
-- ============================================================================
SELECT
    user_id,
    full_name,
    email,
    created_at
FROM users
WHERE is_active = TRUE;


-- ============================================================================
-- 2. WHERE
-- Finds all hard worlds that are currently active.
-- ============================================================================
SELECT
    world_id,
    world_name,
    difficulty_level
FROM worlds
WHERE difficulty_level = 'Hard'
  AND is_active = TRUE;


-- ============================================================================
-- 3. ORDER BY
-- Shows game sessions from newest to oldest.
-- ============================================================================
SELECT
    session_id,
    world_id,
    agent_id,
    result,
    final_score,
    start_time
FROM game_sessions
ORDER BY start_time DESC;


-- ============================================================================
-- 4. INNER JOIN
-- Shows each game session with the player, world, and agent names.
-- ============================================================================
SELECT
    gs.session_id,
    u.full_name AS player_name,
    w.world_name,
    a.agent_name,
    gs.result,
    gs.final_score
FROM game_sessions gs
INNER JOIN users u
    ON gs.played_by = u.user_id
INNER JOIN worlds w
    ON gs.world_id = w.world_id
INNER JOIN agents a
    ON gs.agent_id = a.agent_id
ORDER BY gs.session_id;


-- ============================================================================
-- 5. LEFT JOIN
-- Lists every world and the number of sessions played on it, including worlds
-- with zero sessions.
-- ============================================================================
SELECT
    w.world_id,
    w.world_name,
    COUNT(gs.session_id) AS session_count
FROM worlds w
LEFT JOIN game_sessions gs
    ON w.world_id = gs.world_id
GROUP BY w.world_id, w.world_name
ORDER BY w.world_id;


-- ============================================================================
-- 6. RIGHT JOIN
-- Lists all roles and any users assigned to them. RIGHT JOIN keeps roles even
-- if no user currently has that role.
-- ============================================================================
SELECT
    r.role_name,
    u.full_name
FROM user_roles ur
INNER JOIN users u
    ON ur.user_id = u.user_id
RIGHT JOIN roles r
    ON ur.role_id = r.role_id
ORDER BY r.role_name, u.full_name;


-- ============================================================================
-- 7. GROUP BY with aggregate functions
-- Calculates number of sessions, average score, and best score per agent.
-- ============================================================================
SELECT
    a.agent_name,
    COUNT(gs.session_id) AS sessions_played,
    ROUND(AVG(gs.final_score), 2) AS average_score,
    MAX(gs.final_score) AS best_score
FROM agents a
INNER JOIN game_sessions gs
    ON a.agent_id = gs.agent_id
GROUP BY a.agent_id, a.agent_name
ORDER BY average_score DESC;


-- ============================================================================
-- 8. HAVING
-- Finds agents that have played at least two sessions.
-- ============================================================================
SELECT
    a.agent_name,
    COUNT(gs.session_id) AS sessions_played
FROM agents a
INNER JOIN game_sessions gs
    ON a.agent_id = gs.agent_id
GROUP BY a.agent_id, a.agent_name
HAVING COUNT(gs.session_id) >= 2
ORDER BY sessions_played DESC;


-- ============================================================================
-- 9. Aggregate functions
-- Summarizes overall game performance.
-- ============================================================================
SELECT
    COUNT(*) AS total_sessions,
    COUNT(*) FILTER (WHERE result = 'Won') AS wins,
    COUNT(*) FILTER (WHERE result = 'Died') AS deaths,
    MIN(final_score) AS lowest_score,
    MAX(final_score) AS highest_score,
    ROUND(AVG(final_score), 2) AS average_score
FROM game_sessions;


-- ============================================================================
-- 10. Nested subquery
-- Finds sessions with a score greater than the average score of all sessions.
-- ============================================================================
SELECT
    session_id,
    result,
    final_score
FROM game_sessions
WHERE final_score > (
    SELECT AVG(final_score)
    FROM game_sessions
)
ORDER BY final_score DESC;


-- ============================================================================
-- 11. Nested subquery with IN
-- Finds users who have played at least one winning session.
-- ============================================================================
SELECT
    user_id,
    full_name,
    email
FROM users
WHERE user_id IN (
    SELECT played_by
    FROM game_sessions
    WHERE result = 'Won'
)
ORDER BY full_name;


-- ============================================================================
-- 12. Correlated subquery
-- Finds sessions whose score is above the average score for their own world.
-- ============================================================================
SELECT
    gs.session_id,
    gs.world_id,
    gs.result,
    gs.final_score
FROM game_sessions gs
WHERE gs.final_score > (
    SELECT AVG(gs2.final_score)
    FROM game_sessions gs2
    WHERE gs2.world_id = gs.world_id
)
ORDER BY gs.world_id, gs.final_score DESC;


-- ============================================================================
-- 13. Correlated NOT EXISTS
-- Finds cells that do not contain any hazard.
-- ============================================================================
SELECT
    c.world_id,
    c.row_number,
    c.column_number
FROM cells c
WHERE NOT EXISTS (
    SELECT 1
    FROM cell_hazards ch
    WHERE ch.cell_id = c.cell_id
      AND ch.is_active = TRUE
)
ORDER BY c.world_id, c.row_number, c.column_number;


-- ============================================================================
-- 14. Common Table Expression
-- Calculates win rate per agent.
-- ============================================================================
WITH agent_results AS (
    SELECT
        agent_id,
        COUNT(*) AS total_sessions,
        COUNT(*) FILTER (WHERE result = 'Won') AS won_sessions
    FROM game_sessions
    GROUP BY agent_id
)
SELECT
    a.agent_name,
    ar.total_sessions,
    ar.won_sessions,
    ROUND((ar.won_sessions::NUMERIC / ar.total_sessions) * 100, 2) AS win_rate_percent
FROM agent_results ar
INNER JOIN agents a
    ON ar.agent_id = a.agent_id
ORDER BY win_rate_percent DESC;


-- ============================================================================
-- 15. CTE with multiple steps
-- Finds the most frequently visited cells across all game sessions.
-- ============================================================================
WITH cell_visits AS (
    SELECT
        cell_id,
        COUNT(*) AS visit_count
    FROM game_steps
    GROUP BY cell_id
),
cell_details AS (
    SELECT
        cv.visit_count,
        c.world_id,
        c.row_number,
        c.column_number
    FROM cell_visits cv
    INNER JOIN cells c
        ON cv.cell_id = c.cell_id
)
SELECT
    world_id,
    row_number,
    column_number,
    visit_count
FROM cell_details
ORDER BY visit_count DESC, world_id, row_number, column_number
LIMIT 10;


-- ============================================================================
-- 16. Window function
-- Ranks sessions by score within each world.
-- ============================================================================
SELECT
    session_id,
    world_id,
    result,
    final_score,
    RANK() OVER (
        PARTITION BY world_id
        ORDER BY final_score DESC
    ) AS score_rank_in_world
FROM game_sessions
ORDER BY world_id, score_rank_in_world;


-- ============================================================================
-- 17. Window function with running total
-- Shows the score progression for one session.
-- ============================================================================
SELECT
    session_id,
    step_number,
    score_after_step,
    score_after_step - LAG(score_after_step, 1, 0) OVER (
        PARTITION BY session_id
        ORDER BY step_number
    ) AS score_change
FROM game_steps
WHERE session_id = 1
ORDER BY step_number;


-- ============================================================================
-- 18. JOIN across step perceptions
-- Shows perceptions sensed during session 1.
-- ============================================================================
SELECT
    gs.session_id,
    gs.step_number,
    pt.perception_name,
    c.row_number,
    c.column_number
FROM game_steps gs
INNER JOIN step_perceptions sp
    ON gs.step_id = sp.step_id
INNER JOIN perception_types pt
    ON sp.perception_type_id = pt.perception_type_id
INNER JOIN cells c
    ON gs.cell_id = c.cell_id
WHERE gs.session_id = 1
ORDER BY gs.step_number, pt.perception_name;


-- ============================================================================
-- 19. JOIN for world layout
-- Shows all hazards and their cell positions.
-- ============================================================================
SELECT
    w.world_name,
    ht.hazard_name,
    c.row_number,
    c.column_number
FROM cell_hazards ch
INNER JOIN hazard_types ht
    ON ch.hazard_type_id = ht.hazard_type_id
INNER JOIN cells c
    ON ch.cell_id = c.cell_id
INNER JOIN worlds w
    ON c.world_id = w.world_id
WHERE ch.is_active = TRUE
ORDER BY w.world_id, ht.hazard_name, c.row_number, c.column_number;


-- ============================================================================
-- 20. LEFT JOIN for optional objects
-- Shows all cells in the easy world and any object placed in them.
-- ============================================================================
SELECT
    c.row_number,
    c.column_number,
    COALESCE(ot.object_name, 'No Object') AS object_name
FROM cells c
LEFT JOIN cell_objects co
    ON c.cell_id = co.cell_id
   AND co.is_active = TRUE
LEFT JOIN object_types ot
    ON co.object_type_id = ot.object_type_id
WHERE c.world_id = 1
ORDER BY c.row_number, c.column_number;


-- ============================================================================
-- 21. CREATE OR REPLACE VIEW
-- Creates a reusable view for high-level session summaries.
-- ============================================================================
CREATE OR REPLACE VIEW vw_game_session_summary AS
SELECT
    gs.session_id,
    u.full_name AS player_name,
    w.world_name,
    w.difficulty_level,
    a.agent_name,
    a.agent_type,
    gs.status,
    gs.result,
    gs.final_score,
    gs.total_steps,
    gs.gold_collected,
    gs.agent_survived,
    gs.start_time,
    gs.end_time
FROM game_sessions gs
INNER JOIN users u
    ON gs.played_by = u.user_id
INNER JOIN worlds w
    ON gs.world_id = w.world_id
INNER JOIN agents a
    ON gs.agent_id = a.agent_id;


-- ============================================================================
-- 22. SELECT from view
-- Reads completed sessions from the session summary view.
-- ============================================================================
SELECT
    session_id,
    player_name,
    world_name,
    agent_name,
    result,
    final_score
FROM vw_game_session_summary
WHERE status = 'Completed'
ORDER BY final_score DESC;


-- ============================================================================
-- 23. CREATE OR REPLACE VIEW with aggregation
-- Creates a view showing agent performance statistics.
-- ============================================================================
CREATE OR REPLACE VIEW vw_agent_performance AS
SELECT
    a.agent_id,
    a.agent_name,
    a.agent_type,
    COUNT(gs.session_id) AS total_sessions,
    COUNT(gs.session_id) FILTER (WHERE gs.result = 'Won') AS wins,
    COUNT(gs.session_id) FILTER (WHERE gs.result = 'Died') AS deaths,
    ROUND(AVG(gs.final_score), 2) AS average_score
FROM agents a
LEFT JOIN game_sessions gs
    ON a.agent_id = gs.agent_id
GROUP BY a.agent_id, a.agent_name, a.agent_type;


-- ============================================================================
-- 24. SELECT from aggregate view
-- Shows agent performance from the reusable view.
-- ============================================================================
SELECT
    agent_name,
    agent_type,
    total_sessions,
    wins,
    deaths,
    average_score
FROM vw_agent_performance
ORDER BY average_score DESC NULLS LAST;


-- ============================================================================
-- 25. INSERT inside transaction
-- Demonstrates adding a new viewer user, then rolls back to keep seed data stable.
-- ============================================================================
BEGIN;

INSERT INTO users (
    full_name,
    email,
    password_hash
) VALUES (
    'Kabir Sethi',
    'kabir.sethi@student.ji.edu',
    '$2b$12$samplehashkabirsethi'
)
RETURNING user_id, full_name, email;

ROLLBACK;


-- ============================================================================
-- 26. UPDATE inside transaction
-- Demonstrates deactivating an agent, then rolls back to keep seed data stable.
-- ============================================================================
BEGIN;

UPDATE agents
SET is_active = FALSE
WHERE agent_name = 'Random Walker'
RETURNING agent_id, agent_name, is_active;

ROLLBACK;


-- ============================================================================
-- 27. DELETE inside transaction
-- Demonstrates deleting a user-role assignment, then rolls back to keep seed data stable.
-- ============================================================================
BEGIN;

DELETE FROM user_roles
WHERE user_id = 5
  AND role_id = 4
RETURNING user_role_id, user_id, role_id;

ROLLBACK;


-- ============================================================================
-- 28. Explicit transaction with COMMIT
-- Demonstrates a harmless committed update that refreshes a world's active state.
-- ============================================================================
BEGIN;

UPDATE worlds
SET is_active = TRUE
WHERE world_id = 1;

COMMIT;


-- ============================================================================
-- 29. PostgreSQL function
-- Returns the win rate percentage for a given agent.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_agent_win_rate(p_agent_id INTEGER)
RETURNS NUMERIC(5, 2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sessions INTEGER;
    v_won_sessions INTEGER;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE result = 'Won')
    INTO
        v_total_sessions,
        v_won_sessions
    FROM game_sessions
    WHERE agent_id = p_agent_id;

    IF v_total_sessions = 0 THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND((v_won_sessions::NUMERIC / v_total_sessions) * 100, 2);
END;
$$;


-- ============================================================================
-- 30. Function call
-- Calculates the win rate of the Logic Explorer agent.
-- ============================================================================
SELECT
    a.agent_name,
    fn_agent_win_rate(a.agent_id) AS win_rate_percent
FROM agents a
WHERE a.agent_name = 'Logic Explorer';


-- ============================================================================
-- 31. Stored procedure
-- Marks a running game session as abandoned.
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_abandon_session(p_session_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE game_sessions
    SET
        status = 'Abandoned',
        result = 'Incomplete',
        end_time = CURRENT_TIMESTAMP
    WHERE session_id = p_session_id
      AND status = 'Running';
END;
$$;


-- ============================================================================
-- 32. Procedure call inside rolled-back transaction
-- Demonstrates calling the stored procedure without changing sample data.
-- ============================================================================
BEGIN;

INSERT INTO game_sessions (
    session_id,
    world_id,
    agent_id,
    played_by,
    start_time,
    status,
    result,
    total_steps
) OVERRIDING SYSTEM VALUE VALUES (
    998,
    1,
    3,
    5,
    CURRENT_TIMESTAMP,
    'Running',
    'Incomplete',
    0
);

CALL sp_abandon_session(998);

SELECT
    session_id,
    status,
    result,
    end_time
FROM game_sessions
WHERE session_id = 998;

ROLLBACK;


-- ============================================================================
-- 33. Trigger support function
-- Keeps game_sessions.total_steps synchronized when a new game step is inserted.
-- ============================================================================
CREATE OR REPLACE FUNCTION trg_update_total_steps()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE game_sessions
    SET total_steps = (
        SELECT COUNT(*)
        FROM game_steps
        WHERE session_id = NEW.session_id
    )
    WHERE session_id = NEW.session_id;

    RETURN NEW;
END;
$$;


-- ============================================================================
-- 34. Trigger
-- Fires after inserting a game step and updates the parent session's total_steps.
-- ============================================================================
DROP TRIGGER IF EXISTS after_game_step_insert_update_total ON game_steps;

CREATE TRIGGER after_game_step_insert_update_total
AFTER INSERT ON game_steps
FOR EACH ROW
EXECUTE FUNCTION trg_update_total_steps();


-- ============================================================================
-- 35. Trigger demonstration inside rolled-back transaction
-- Inserts a temporary running session and one step to prove the trigger updates
-- total_steps automatically, then rolls back.
-- ============================================================================
BEGIN;

INSERT INTO game_sessions (
    session_id,
    world_id,
    agent_id,
    played_by,
    start_time,
    status,
    result,
    total_steps
) OVERRIDING SYSTEM VALUE VALUES (
    999,
    1,
    1,
    3,
    CURRENT_TIMESTAMP,
    'Running',
    'Incomplete',
    0
);

INSERT INTO game_steps (
    session_id,
    step_number,
    cell_id,
    action_type_id,
    direction_facing,
    action_successful,
    score_after_step
) VALUES (
    999,
    1,
    1,
    7,
    'East',
    TRUE,
    -1
);

SELECT
    session_id,
    total_steps
FROM game_sessions
WHERE session_id = 999;

ROLLBACK;


-- ============================================================================
-- 36. CASE expression
-- Classifies session outcomes into readable performance labels.
-- ============================================================================
SELECT
    session_id,
    result,
    final_score,
    CASE
        WHEN result = 'Won' THEN 'Successful exploration'
        WHEN result = 'Died' THEN 'Fatal exploration'
        WHEN result = 'Escaped Without Gold' THEN 'Safe but incomplete'
        ELSE 'Not completed'
    END AS performance_label
FROM game_sessions
ORDER BY session_id;


-- ============================================================================
-- 37. DISTINCT
-- Lists the different difficulty levels currently used by worlds.
-- ============================================================================
SELECT DISTINCT
    difficulty_level
FROM worlds
ORDER BY difficulty_level;


-- ============================================================================
-- 38. LIMIT
-- Shows the top three scoring sessions.
-- ============================================================================
SELECT
    session_id,
    result,
    final_score
FROM game_sessions
ORDER BY final_score DESC
LIMIT 3;


-- ============================================================================
-- 39. EXISTS
-- Finds worlds that have at least one active Wumpus.
-- ============================================================================
SELECT
    w.world_id,
    w.world_name
FROM worlds w
WHERE EXISTS (
    SELECT 1
    FROM cells c
    INNER JOIN cell_hazards ch
        ON c.cell_id = ch.cell_id
    INNER JOIN hazard_types ht
        ON ch.hazard_type_id = ht.hazard_type_id
    WHERE c.world_id = w.world_id
      AND ht.hazard_name = 'Wumpus'
      AND ch.is_active = TRUE
)
ORDER BY w.world_id;


-- ============================================================================
-- 40. Self-contained report query
-- Produces a compact report of world difficulty, hazards, sessions, and wins.
-- ============================================================================
SELECT
    w.world_name,
    w.difficulty_level,
    COUNT(DISTINCT ch.cell_hazard_id) AS hazard_count,
    COUNT(DISTINCT gs.session_id) AS session_count,
    COUNT(DISTINCT gs.session_id) FILTER (WHERE gs.result = 'Won') AS win_count
FROM worlds w
LEFT JOIN cells c
    ON w.world_id = c.world_id
LEFT JOIN cell_hazards ch
    ON c.cell_id = ch.cell_id
   AND ch.is_active = TRUE
LEFT JOIN game_sessions gs
    ON w.world_id = gs.world_id
GROUP BY w.world_id, w.world_name, w.difficulty_level
ORDER BY w.world_id;
