from flask import Blueprint, flash, redirect, render_template, request, url_for
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from database import db
from models import User, World


worlds_bp = Blueprint("worlds", __name__, url_prefix="/worlds")
DIFFICULTY_LEVELS = ["Easy", "Medium", "Hard", "Custom"]


def validate_world_form(form):
    errors = []
    world_name = form.get("world_name", "").strip()
    description = form.get("description", "").strip() or None
    difficulty_level = form.get("difficulty_level", "Custom")
    is_active = form.get("is_active") == "on"

    try:
        created_by = int(form.get("created_by", ""))
    except ValueError:
        created_by = None
        errors.append("Creator is required.")

    try:
        grid_rows = int(form.get("grid_rows", ""))
        grid_columns = int(form.get("grid_columns", ""))
    except ValueError:
        grid_rows = None
        grid_columns = None
        errors.append("Grid rows and columns must be numbers.")

    if not world_name:
        errors.append("World name is required.")
    if grid_rows is not None and not 2 <= grid_rows <= 50:
        errors.append("Grid rows must be between 2 and 50.")
    if grid_columns is not None and not 2 <= grid_columns <= 50:
        errors.append("Grid columns must be between 2 and 50.")
    if difficulty_level not in DIFFICULTY_LEVELS:
        errors.append("Invalid difficulty level.")
    if created_by and not db.session.get(User, created_by):
        errors.append("Selected creator does not exist.")

    return errors, {
        "created_by": created_by,
        "world_name": world_name,
        "description": description,
        "grid_rows": grid_rows,
        "grid_columns": grid_columns,
        "difficulty_level": difficulty_level,
        "is_active": is_active,
    }


@worlds_bp.route("/")
def list_worlds():
    worlds = db.session.execute(db.select(World).order_by(World.world_id)).scalars().all()
    return render_template("worlds/list.html", worlds=worlds)


@worlds_bp.route("/new", methods=["GET", "POST"])
def create_world():
    users = db.session.execute(db.select(User).where(User.is_active == True).order_by(User.full_name)).scalars().all()

    if request.method == "POST":
        errors, data = validate_world_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("worlds/form.html", world=data, users=users, difficulties=DIFFICULTY_LEVELS, mode="create")

        world = World(**data)
        db.session.add(world)
        try:
            db.session.commit()
            flash("World created successfully.", "success")
            return redirect(url_for("worlds.list_worlds"))
        except IntegrityError:
            db.session.rollback()
            flash("This creator already has a world with that name.", "error")
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("worlds/form.html", world=None, users=users, difficulties=DIFFICULTY_LEVELS, mode="create")


@worlds_bp.route("/<int:world_id>/edit", methods=["GET", "POST"])
def edit_world(world_id):
    world = db.get_or_404(World, world_id)
    users = db.session.execute(db.select(User).where(User.is_active == True).order_by(User.full_name)).scalars().all()

    if request.method == "POST":
        errors, data = validate_world_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("worlds/form.html", world=world, users=users, difficulties=DIFFICULTY_LEVELS, mode="edit")

        for key, value in data.items():
            setattr(world, key, value)

        try:
            db.session.commit()
            flash("World updated successfully.", "success")
            return redirect(url_for("worlds.list_worlds"))
        except IntegrityError:
            db.session.rollback()
            flash("This creator already has a world with that name.", "error")
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("worlds/form.html", world=world, users=users, difficulties=DIFFICULTY_LEVELS, mode="edit")


@worlds_bp.route("/<int:world_id>/delete", methods=["POST"])
def delete_world(world_id):
    world = db.get_or_404(World, world_id)
    try:
        db.session.delete(world)
        db.session.commit()
        flash("World deleted successfully.", "success")
    except IntegrityError:
        db.session.rollback()
        flash("This world is linked to game sessions and cannot be deleted.", "error")
    except SQLAlchemyError as exc:
        db.session.rollback()
        flash(f"Database error: {exc}", "error")

    return redirect(url_for("worlds.list_worlds"))
