from datetime import datetime

from flask import Blueprint, flash, redirect, render_template, request, url_for
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from database import db
from models import Agent, GameSession, GameStep, User, World


game_sessions_bp = Blueprint("game_sessions", __name__, url_prefix="/game-sessions")
STATUSES = ["Running", "Completed", "Failed", "Abandoned"]
RESULTS = ["Won", "Died", "Died (Fell in Pit)", "Died (Eaten by Wumpus)", "Escaped Without Gold", "Incomplete"]


def parse_datetime(value):
    value = (value or "").strip()
    if not value:
        return None
    try:
        return datetime.fromisoformat(value)
    except ValueError:
        pass
    
    formats = [
        "%m/%d/%Y, %I:%M %p",
        "%m/%d/%Y %I:%M %p",
        "%Y-%m-%dT%H:%M",
        "%Y-%m-%d %H:%M:%S"
    ]
    for fmt in formats:
        try:
            return datetime.strptime(value, fmt)
        except ValueError:
            continue
    raise ValueError("Invalid date format")


def validate_session_form(form):
    errors = []
    status = form.get("status", "Running")
    result = form.get("result", "Incomplete")
    gold_collected = form.get("gold_collected") == "on"
    agent_survived = form.get("agent_survived") == "on"

    try:
        world_id = int(form.get("world_id", ""))
    except ValueError:
        world_id = None
        errors.append("World is required.")

    try:
        agent_id = int(form.get("agent_id", ""))
    except ValueError:
        agent_id = None
        errors.append("Agent is required.")

    try:
        played_by = int(form.get("played_by", ""))
    except ValueError:
        played_by = None
        errors.append("Player is required.")

    try:
        final_score = int(form.get("final_score", "0"))
        total_steps = int(form.get("total_steps", "0"))
    except ValueError:
        final_score = 0
        total_steps = 0
        errors.append("Final score and total steps must be numbers.")

    try:
        end_time = parse_datetime(form.get("end_time"))
    except ValueError:
        end_time = None
        errors.append("End time must use a valid date-time format.")

    if world_id and not db.session.get(World, world_id):
        errors.append("Selected world does not exist.")
    if agent_id and not db.session.get(Agent, agent_id):
        errors.append("Selected agent does not exist.")
    if played_by and not db.session.get(User, played_by):
        errors.append("Selected player does not exist.")
    if status not in STATUSES:
        errors.append("Invalid session status.")
    if result not in RESULTS:
        errors.append("Invalid session result.")
    if total_steps < 0:
        errors.append("Total steps cannot be negative.")
    if status == "Running" and end_time is not None:
        errors.append("Running sessions cannot have an end time.")
    if status != "Running" and end_time is None:
        errors.append("Completed, failed, or abandoned sessions must have an end time.")

    return errors, {
        "world_id": world_id,
        "agent_id": agent_id,
        "played_by": played_by,
        "end_time": end_time,
        "status": status,
        "result": result,
        "final_score": final_score,
        "total_steps": total_steps,
        "gold_collected": gold_collected,
        "agent_survived": agent_survived,
    }


def load_form_options():
    return {
        "worlds": db.session.execute(db.select(World).order_by(World.world_name)).scalars().all(),
        "agents": db.session.execute(db.select(Agent).order_by(Agent.agent_name)).scalars().all(),
        "users": db.session.execute(db.select(User).order_by(User.full_name)).scalars().all(),
        "statuses": STATUSES,
        "results": RESULTS,
    }


@game_sessions_bp.route("/")
def list_game_sessions():
    sessions = (
        db.session.execute(db.select(GameSession).order_by(GameSession.start_time.desc()))
        .scalars()
        .all()
    )
    return render_template("game_sessions/list.html", sessions=sessions)


@game_sessions_bp.route("/history")
def game_history():
    selected_session_id = request.args.get("session_id", type=int)
    sessions = (
        db.session.execute(db.select(GameSession).order_by(GameSession.start_time.desc()))
        .scalars()
        .all()
    )

    steps_query = db.select(GameStep).join(GameStep.session).order_by(
        GameSession.session_id,
        GameStep.step_number,
    )
    if selected_session_id:
        steps_query = steps_query.where(GameStep.session_id == selected_session_id)

    steps = db.session.execute(steps_query).scalars().all()
    return render_template(
        "game_history.html",
        sessions=sessions,
        steps=steps,
        selected_session_id=selected_session_id,
    )


@game_sessions_bp.route("/new", methods=["GET", "POST"])
def create_game_session():
    options = load_form_options()

    if request.method == "POST":
        errors, data = validate_session_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("game_sessions/form.html", session=data, mode="create", **options)

        import random
        from datetime import datetime
        
        # Use weights to make 'Completed' and 'Failed' more common than 'Running' and 'Abandoned'
        # This makes the results (Won/Died) and scores appear much more varied!
        data["status"] = random.choices(
            STATUSES,
            weights=[10, 40, 40, 10],
            k=1
        )[0]
        
        if data["status"] == "Failed":
            data["result"] = random.choice(["Died (Fell in Pit)", "Died (Eaten by Wumpus)"])
        elif data["status"] == "Abandoned" or data["status"] == "Running":
            data["result"] = "Incomplete"
        else:
            data["result"] = random.choice(["Won", "Escaped Without Gold"])
            
        data["total_steps"] = random.randint(5, 300)
        
        # Determine rules based on Result
        base_score = 0
        arrows_shot = random.choice([0, 1])
        
        if data["result"] == "Won":
            base_score = 1000
            data["gold_collected"] = True
            data["agent_survived"] = True
        elif "Died" in data["result"]:
            base_score = -1000
            data["gold_collected"] = random.choice([True, False]) # could have collected before dying
            data["agent_survived"] = False
        elif data["result"] == "Escaped Without Gold":
            base_score = 0
            data["gold_collected"] = False
            data["agent_survived"] = True
        else: # Incomplete
            base_score = 0
            data["gold_collected"] = random.choice([True, False])
            data["agent_survived"] = True

        # Calculate final score according to Wumpus World Rules
        # +1000 (Win), -1000 (Die), -1 (Every Action/Step), -10 (Shoot Arrow)
        data["final_score"] = base_score - data["total_steps"] - (arrows_shot * 10)
        
        if data["status"] != "Running":
            data["end_time"] = datetime.now()
        else:
            data["end_time"] = None

        session = GameSession(**data)
        db.session.add(session)
        try:
            db.session.commit()
            flash("Game session created successfully.", "success")
            return redirect(url_for("game_sessions.list_game_sessions"))
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("game_sessions/form.html", session=None, mode="create", **options)


@game_sessions_bp.route("/<int:session_id>/edit", methods=["GET", "POST"])
def edit_game_session(session_id):
    session = db.get_or_404(GameSession, session_id)
    options = load_form_options()

    if request.method == "POST":
        errors, data = validate_session_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("game_sessions/form.html", session=session, mode="edit", **options)

        for key, value in data.items():
            setattr(session, key, value)

        try:
            db.session.commit()
            flash("Game session updated successfully.", "success")
            return redirect(url_for("game_sessions.list_game_sessions"))
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("game_sessions/form.html", session=session, mode="edit", **options)


@game_sessions_bp.route("/<int:session_id>/delete", methods=["POST"])
def delete_game_session(session_id):
    session = db.get_or_404(GameSession, session_id)
    try:
        db.session.delete(session)
        db.session.commit()
        flash("Game session deleted successfully.", "success")
    except IntegrityError:
        db.session.rollback()
        flash("This game session has related records and cannot be deleted.", "error")
    except SQLAlchemyError as exc:
        db.session.rollback()
        flash(f"Database error: {exc}", "error")

    return redirect(url_for("game_sessions.list_game_sessions"))
