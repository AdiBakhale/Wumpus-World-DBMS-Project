from database import db


class User(db.Model):
    __tablename__ = "users"

    user_id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(255), nullable=False, unique=True)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime(timezone=True), server_default=db.func.current_timestamp(), nullable=False)
    is_active = db.Column(db.Boolean, nullable=False, default=True)

    worlds = db.relationship("World", back_populates="creator", foreign_keys="World.created_by")
    agents = db.relationship("Agent", back_populates="creator", foreign_keys="Agent.created_by")
    game_sessions = db.relationship("GameSession", back_populates="player", foreign_keys="GameSession.played_by")


class World(db.Model):
    __tablename__ = "worlds"

    world_id = db.Column(db.Integer, primary_key=True)
    created_by = db.Column(db.Integer, db.ForeignKey("users.user_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    world_name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    grid_rows = db.Column(db.Integer, nullable=False)
    grid_columns = db.Column(db.Integer, nullable=False)
    difficulty_level = db.Column(db.String(20), nullable=False, default="Custom")
    created_at = db.Column(db.DateTime(timezone=True), server_default=db.func.current_timestamp(), nullable=False)
    is_active = db.Column(db.Boolean, nullable=False, default=True)

    creator = db.relationship("User", back_populates="worlds", foreign_keys=[created_by])
    sessions = db.relationship("GameSession", back_populates="world")


class Agent(db.Model):
    __tablename__ = "agents"

    agent_id = db.Column(db.Integer, primary_key=True)
    created_by = db.Column(db.Integer, db.ForeignKey("users.user_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    agent_name = db.Column(db.String(100), nullable=False)
    agent_type = db.Column(db.String(30), nullable=False)
    strategy_description = db.Column(db.Text)
    created_at = db.Column(db.DateTime(timezone=True), server_default=db.func.current_timestamp(), nullable=False)
    is_active = db.Column(db.Boolean, nullable=False, default=True)

    creator = db.relationship("User", back_populates="agents", foreign_keys=[created_by])
    sessions = db.relationship("GameSession", back_populates="agent")


class GameSession(db.Model):
    __tablename__ = "game_sessions"

    session_id = db.Column(db.Integer, primary_key=True)
    world_id = db.Column(db.Integer, db.ForeignKey("worlds.world_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    agent_id = db.Column(db.Integer, db.ForeignKey("agents.agent_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    played_by = db.Column(db.Integer, db.ForeignKey("users.user_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    start_time = db.Column(db.DateTime(timezone=True), server_default=db.func.current_timestamp(), nullable=False)
    end_time = db.Column(db.DateTime(timezone=True))
    status = db.Column(db.String(20), nullable=False, default="Running")
    result = db.Column(db.String(30), nullable=False, default="Incomplete")
    final_score = db.Column(db.Integer, nullable=False, default=0)
    total_steps = db.Column(db.Integer, nullable=False, default=0)
    gold_collected = db.Column(db.Boolean, nullable=False, default=False)
    agent_survived = db.Column(db.Boolean, nullable=False, default=True)

    world = db.relationship("World", back_populates="sessions")
    agent = db.relationship("Agent", back_populates="sessions")
    player = db.relationship("User", back_populates="game_sessions", foreign_keys=[played_by])
    steps = db.relationship("GameStep", back_populates="session", order_by="GameStep.step_number")


class Cell(db.Model):
    __tablename__ = "cells"

    cell_id = db.Column(db.Integer, primary_key=True)
    world_id = db.Column(db.Integer, db.ForeignKey("worlds.world_id"), nullable=False)
    row_number = db.Column(db.Integer, nullable=False)
    column_number = db.Column(db.Integer, nullable=False)
    is_start_cell = db.Column(db.Boolean, nullable=False, default=False)

    steps = db.relationship("GameStep", back_populates="cell")


class ActionType(db.Model):
    __tablename__ = "action_types"

    action_type_id = db.Column(db.Integer, primary_key=True)
    action_name = db.Column(db.String(50), nullable=False, unique=True)
    description = db.Column(db.Text)

    steps = db.relationship("GameStep", back_populates="action_type")


class GameStep(db.Model):
    __tablename__ = "game_steps"

    step_id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey("game_sessions.session_id", onupdate="CASCADE", ondelete="CASCADE"), nullable=False)
    step_number = db.Column(db.Integer, nullable=False)
    cell_id = db.Column(db.Integer, db.ForeignKey("cells.cell_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    action_type_id = db.Column(db.Integer, db.ForeignKey("action_types.action_type_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    direction_facing = db.Column(db.String(10), nullable=False)
    action_successful = db.Column(db.Boolean, nullable=False, default=True)
    score_after_step = db.Column(db.Integer, nullable=False)
    step_time = db.Column(db.DateTime(timezone=True), server_default=db.func.current_timestamp(), nullable=False)

    session = db.relationship("GameSession", back_populates="steps")
    cell = db.relationship("Cell", back_populates="steps")
    action_type = db.relationship("ActionType", back_populates="steps")
    perceptions = db.relationship("StepPerception", back_populates="step")


class PerceptionType(db.Model):
    __tablename__ = "perception_types"

    perception_type_id = db.Column(db.Integer, primary_key=True)
    perception_name = db.Column(db.String(50), nullable=False, unique=True)
    description = db.Column(db.Text)

    step_perceptions = db.relationship("StepPerception", back_populates="perception_type")


class StepPerception(db.Model):
    __tablename__ = "step_perceptions"

    step_perception_id = db.Column(db.Integer, primary_key=True)
    step_id = db.Column(db.Integer, db.ForeignKey("game_steps.step_id", onupdate="CASCADE", ondelete="CASCADE"), nullable=False)
    perception_type_id = db.Column(db.Integer, db.ForeignKey("perception_types.perception_type_id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)

    step = db.relationship("GameStep", back_populates="perceptions")
    perception_type = db.relationship("PerceptionType", back_populates="step_perceptions")
