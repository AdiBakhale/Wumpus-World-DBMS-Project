# Wumpus World Database Management System
**Project Overview & General Documentation**

**Project Team:** Milind Nevrekar and Team Members

---

## 1. Introduction

The **Wumpus World** is a foundational Artificial Intelligence (AI) problem designed to simulate a knowledge-based agent exploring an unknown, hazardous environment. In this classic grid-based game, the agent must navigate through a cave system to find hidden gold, grab it, and safely return to the entrance—all while avoiding deadly bottomless pits and the fearsome Wumpus monster. 

The core challenge of the Wumpus World is that the environment is **partially observable**. The agent cannot see hazards directly. Instead, it must rely on environmental percepts (like a "Stench" if the Wumpus is nearby, or a "Breeze" if a pit is adjacent) and use **logical inference** to deduce which grid cells are safe to step on and which mean certain death.

---

## 2. Project Goal

The primary goal of this project is to build a comprehensive **Database Management System (DBMS)** capable of storing, managing, and analyzing thousands of these Wumpus World simulation runs. 

While building a Wumpus World AI is a common exercise, tracking the long-term performance, comparing different AI algorithms, and finding patterns in how agents die requires a robust operational database. This project solves that problem by providing a full-stack web application tailored exclusively to recording Wumpus World game sessions.

### Key Objectives
- **Data Persistence:** Create a highly normalized relational database to store every aspect of the simulation (Users, Worlds, Agents, Game Sessions, and Game Steps).
- **Session Management:** Build an intuitive user interface to create new sessions, assign agents to worlds, and view results.
- **Automated Validation:** Ensure that any data written to the database strictly adheres to Wumpus World logic (e.g., an agent cannot "Win" if they fell in a pit).
- **Analytics & Reporting:** Enable complex SQL queries to calculate win rates, average scores, and step counts across different AI algorithms.

---

## 3. Project Scope & Functionality

The Wumpus World DBMS provides a complete suite of tools for researchers and players to track simulations.

### 3.1 Entity Management
The system allows users to define the building blocks of a simulation:
- **Worlds:** Users can register different cave layouts, specifying the size of the grid and the difficulty.
- **Agents:** Users can register different AI models (e.g., "Basic Logic Agent", "Probabilistic Agent") to compare their performance.
- **Players/Users:** Human overseers who initiate the simulations.

### 3.2 Game Session Generation
The core feature of the web interface is the **Game Session Creator**. When a user selects a World, Agent, and Player, the system generates a simulated game session.
- **Randomized Logic Engine:** The backend uses weighted probabilities to determine if the agent successfully completed the world or failed.
- **Strict Adherence to Rules:** If the agent fails, the system accurately records the cause of death (either eaten by the Wumpus or falling into a pit).
- **Automated Scoring:** The system calculates the final score based on the official Wumpus World Performance Measures (+1000 for winning, -1000 for dying, -1 for every step taken, and -10 for shooting an arrow).

### 3.3 Simulation Replay (Data Warehouse)
Because the system stores every individual **Game Step** (including what percepts were felt on that specific turn, and what action the agent took), the data can be used to reconstruct and "replay" the game visually on the frontend, allowing users to watch the AI's decision-making process step-by-step.

---

## 4. Value & Applications

This DBMS project elevates the standard Wumpus World exercise by treating it as a real-world data engineering problem. 
- **Educational Value:** It bridges the gap between AI theory (inference rules) and Database theory (normalization, constraints, and web development).
- **Scalability:** The architecture is designed to handle massive amounts of data, making it a scalable solution for machine learning researchers who might run millions of training epochs and need a structured database to store the historical results.
