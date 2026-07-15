from flask import Blueprint, flash, redirect, render_template, request, url_for
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from database import db
from models import Agent, User


agents_bp = Blueprint("agents", __name__, url_prefix="/agents")
AGENT_TYPES = ["Human", "Random", "Rule-Based", "Logic-Based"]


def validate_agent_form(form):
    errors = []
    agent_name = form.get("agent_name", "").strip()
    agent_type = form.get("agent_type", "")
    strategy_description = form.get("strategy_description", "").strip() or None
    is_active = form.get("is_active") == "on"

    try:
        created_by = int(form.get("created_by", ""))
    except ValueError:
        created_by = None
        errors.append("Creator is required.")

    if not agent_name:
        errors.append("Agent name is required.")
    if agent_type not in AGENT_TYPES:
        errors.append("Invalid agent type.")
    if created_by and not db.session.get(User, created_by):
        errors.append("Selected creator does not exist.")

    return errors, {
        "created_by": created_by,
        "agent_name": agent_name,
        "agent_type": agent_type,
        "strategy_description": strategy_description,
        "is_active": is_active,
    }


@agents_bp.route("/")
def list_agents():
    agents = db.session.execute(db.select(Agent).order_by(Agent.agent_id)).scalars().all()
    return render_template("agents/list.html", agents=agents)


@agents_bp.route("/new", methods=["GET", "POST"])
def create_agent():
    users = db.session.execute(db.select(User).where(User.is_active == True).order_by(User.full_name)).scalars().all()

    if request.method == "POST":
        errors, data = validate_agent_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("agents/form.html", agent=data, users=users, agent_types=AGENT_TYPES, mode="create")

        agent = Agent(**data)
        db.session.add(agent)
        try:
            db.session.commit()
            flash("Agent created successfully.", "success")
            return redirect(url_for("agents.list_agents"))
        except IntegrityError:
            db.session.rollback()
            flash("This creator already has an agent with that name.", "error")
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("agents/form.html", agent=None, users=users, agent_types=AGENT_TYPES, mode="create")


@agents_bp.route("/<int:agent_id>/edit", methods=["GET", "POST"])
def edit_agent(agent_id):
    agent = db.get_or_404(Agent, agent_id)
    users = db.session.execute(db.select(User).where(User.is_active == True).order_by(User.full_name)).scalars().all()

    if request.method == "POST":
        errors, data = validate_agent_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("agents/form.html", agent=agent, users=users, agent_types=AGENT_TYPES, mode="edit")

        for key, value in data.items():
            setattr(agent, key, value)

        try:
            db.session.commit()
            flash("Agent updated successfully.", "success")
            return redirect(url_for("agents.list_agents"))
        except IntegrityError:
            db.session.rollback()
            flash("This creator already has an agent with that name.", "error")
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("agents/form.html", agent=agent, users=users, agent_types=AGENT_TYPES, mode="edit")


@agents_bp.route("/<int:agent_id>/delete", methods=["POST"])
def delete_agent(agent_id):
    agent = db.get_or_404(Agent, agent_id)
    try:
        db.session.delete(agent)
        db.session.commit()
        flash("Agent deleted successfully.", "success")
    except IntegrityError:
        db.session.rollback()
        flash("This agent is linked to game sessions and cannot be deleted.", "error")
    except SQLAlchemyError as exc:
        db.session.rollback()
        flash(f"Database error: {exc}", "error")

    return redirect(url_for("agents.list_agents"))
