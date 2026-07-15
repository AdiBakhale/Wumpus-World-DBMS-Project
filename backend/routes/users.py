import re

from flask import Blueprint, flash, redirect, render_template, request, url_for
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from database import db
from models import User


users_bp = Blueprint("users", __name__, url_prefix="/users")
EMAIL_PATTERN = re.compile(r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$", re.IGNORECASE)


def validate_user_form(form, require_password=True):
    errors = []
    full_name = form.get("full_name", "").strip()
    email = form.get("email", "").strip().lower()
    password_hash = form.get("password_hash", "").strip()
    is_active = form.get("is_active") == "on"

    if not full_name:
        errors.append("Full name is required.")
    if not EMAIL_PATTERN.match(email):
        errors.append("A valid email address is required.")
    if require_password and not password_hash:
        errors.append("Password hash is required.")

    return errors, {
        "full_name": full_name,
        "email": email,
        "password_hash": password_hash,
        "is_active": is_active,
    }


@users_bp.route("/")
def list_users():
    users = db.session.execute(db.select(User).order_by(User.user_id)).scalars().all()
    return render_template("users/list.html", users=users)


@users_bp.route("/new", methods=["GET", "POST"])
def create_user():
    if request.method == "POST":
        errors, data = validate_user_form(request.form)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("users/form.html", user=data, mode="create")

        user = User(**data)
        db.session.add(user)
        try:
            db.session.commit()
            flash("User created successfully.", "success")
            return redirect(url_for("users.list_users"))
        except IntegrityError:
            db.session.rollback()
            flash("A user with this email already exists.", "error")
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("users/form.html", user=None, mode="create")


@users_bp.route("/<int:user_id>/edit", methods=["GET", "POST"])
def edit_user(user_id):
    user = db.get_or_404(User, user_id)

    if request.method == "POST":
        errors, data = validate_user_form(request.form, require_password=False)
        if errors:
            for error in errors:
                flash(error, "error")
            return render_template("users/form.html", user=user, mode="edit")

        user.full_name = data["full_name"]
        user.email = data["email"]
        user.is_active = data["is_active"]
        if data["password_hash"]:
            user.password_hash = data["password_hash"]

        try:
            db.session.commit()
            flash("User updated successfully.", "success")
            return redirect(url_for("users.list_users"))
        except IntegrityError:
            db.session.rollback()
            flash("A user with this email already exists.", "error")
        except SQLAlchemyError as exc:
            db.session.rollback()
            flash(f"Database error: {exc}", "error")

    return render_template("users/form.html", user=user, mode="edit")


@users_bp.route("/<int:user_id>/delete", methods=["POST"])
def delete_user(user_id):
    user = db.get_or_404(User, user_id)
    try:
        db.session.delete(user)
        db.session.commit()
        flash("User deleted successfully.", "success")
    except IntegrityError:
        db.session.rollback()
        flash("This user is linked to worlds, agents, or game sessions and cannot be deleted.", "error")
    except SQLAlchemyError as exc:
        db.session.rollback()
        flash(f"Database error: {exc}", "error")

    return redirect(url_for("users.list_users"))
