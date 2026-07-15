# Wumpus World Database Management System
**Comprehensive Project Report**

---

## 1. Introduction

### 1.1 Problem Statement
The "Wumpus World" is a classic Artificial Intelligence (AI) environment used to demonstrate how a knowledge-based agent uses logical reasoning and inference to make decisions in an unknown environment. As the complexity of simulating this environment grows, there is a distinct need for a robust system to record, track, and analyze agent behaviors over thousands of iterations. The objective of this project is to design and implement a complete Database Management System (DBMS) that stores operational data for Wumpus World game sessions, empowering researchers and players to monitor performance, analyze decision-making efficiency, and compare various agents.

### 1.2 Objectives
1. Design a normalized, highly scalable operational relational database.
2. Develop a backend web interface that allows users to create and manage game sessions.
3. Automatically apply Wumpus World logic and performance measurement rules to game sessions.
4. Record granular game step data, including the agent's percepts (Breeze, Stench, etc.) and actions.
5. Provide reporting structures to track the most successful agents, the hardest worlds, and common causes of death.

### 1.3 Scope of the Project
The system manages:
- **Users**: Humans observing or initiating the sessions.
- **Agents**: The AI algorithms or distinct entities making decisions.
- **Worlds**: The dynamically generated 4x4 grid caves containing pits, the Wumpus, and gold.
- **Game Sessions**: The overarching metadata of an agent attempting a world.
- **Game Steps**: A chronological, step-by-step history of every single move, perception, and score change within a session.

---

## 2. Wumpus World Environment & Rules

The Wumpus World is a **4×4 grid** (16 total rooms) where the agent starts at `(1,1)`. The agent's goal is to find the gold, pick it up, and return safely to the starting square to climb out of the cave.

### 2.1 The Hazards
- **Wumpus**: A dangerous monster that occupies one room. If the agent enters its room, the agent dies. It can be killed with a single arrow.
- **Pits**: Deep holes. If the agent enters a pit, it immediately dies. There can be multiple pits.

### 2.2 The Percepts
The agent cannot see hazards directly. It senses them via clues:
- **Stench**: The Wumpus is in an adjacent (Up/Down/Left/Right) cell.
- **Breeze**: A Pit is in an adjacent cell.
- **Glitter**: The Gold is in the current cell.
- **Bump**: The agent hit a wall.
- **Scream**: The Wumpus has been killed.

### 2.3 Official Performance Measure (Scoring)
The system calculates scores automatically based on the following rules:
- **Find Gold and Exit**: `+1000` Points
- **Die**: `-1000` Points
- **Every Action/Step**: `-1` Point
- **Shoot Arrow**: `-10` Points

---

## 3. System Architecture & Database Design

The project is built on a **PostgreSQL** relational database backend with a **Flask (Python)** web interface.

### 3.1 Database Entities
1. **Users**: Stores `user_id`, `username`, and `full_name`.
2. **Worlds**: Stores `world_id`, `world_name`, and size dimensions.
3. **Cells**: Defines every coordinate `(row, col)` belonging to a specific `world_id`.
4. **Agents**: Stores `agent_id`, `agent_name`, and metadata about the AI.
5. **Game Sessions**: Ties together a user, world, and agent. Records the overarching outcome (Win/Loss), final score, total steps, and timestamps.
6. **Game Steps**: Records the granular step-by-step moves. Links a `session_id` to a `cell_id`, capturing the `action_type`, `direction_facing`, and the running score.
7. **Step Perceptions**: A many-to-many junction table mapping specific percepts (Stench, Breeze) to specific game steps.

### 3.2 Automated Session Management
The backend features an automated session generator. When a user requests a new game session, they only specify the **World**, **Agent**, and **Player**. The system then utilizes a weighted generation engine to simulate the outcome:
- **Weighted Probabilities**: The system heavily weights the `Completed` and `Failed` statuses (40% each) to ensure highly varied and realistic outcomes, while `Running` and `Abandoned` occur less frequently (10% each).
- **Death Classification**: If an agent fails, the system randomly assigns a specific cause of death: `Died (Fell in Pit)` or `Died (Eaten by Wumpus)`.
- **Scoring Constraints**: The final score is strictly calculated using the Wumpus World Performance Measures. For example, an agent that dies in a pit after taking 15 steps will automatically be assigned a score of `-1015`.

---

## 4. Conclusion

The Wumpus World Database Management System successfully bridges the gap between classic AI theory and modern data engineering. By creating a normalized schema that captures both high-level session outcomes and granular, step-by-step percept/action data, the system provides a perfect foundation for analyzing agent efficiency, validating logical inference rules, and observing the core tenets of AI decision-making.
