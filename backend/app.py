from flask import Flask, flash, redirect, render_template, url_for
from sqlalchemy import func
from sqlalchemy.exc import SQLAlchemyError

from config import Config
from database import check_database_connection, db
from models import Agent, GameSession, User, World
from routes.agents import agents_bp
from routes.game_sessions import game_sessions_bp
from routes.users import users_bp
from routes.worlds import worlds_bp
from routes.simulation import simulation_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)

    # For quick local development without PostgreSQL, if the configured
    # database is SQLite, auto-create tables so the app can run out-of-the-box.
    if app.config.get("SQLALCHEMY_DATABASE_URI", "").startswith("sqlite"):
        with app.app_context():
            try:
                db.create_all()
            except Exception as exc:  # pragma: no cover - best-effort dev helper
                app.logger.warning(f"Automatic SQLite table creation failed: {exc}")

    app.register_blueprint(users_bp)
    app.register_blueprint(worlds_bp)
    app.register_blueprint(agents_bp)
    app.register_blueprint(game_sessions_bp)
    app.register_blueprint(simulation_bp)
    
    @app.route("/")
    def dashboard():
        db_ok, db_message = check_database_connection()
        if not db_ok:
            flash(f"Database connection failed: {db_message}", "error")
            return render_template("index.html", db_ok=False, stats={})

        stats = {
            "users": db.session.scalar(db.select(func.count(User.user_id))),
            "worlds": db.session.scalar(db.select(func.count(World.world_id))),
            "agents": db.session.scalar(db.select(func.count(Agent.agent_id))),
            "sessions": db.session.scalar(db.select(func.count(GameSession.session_id))),
            "wins": db.session.scalar(
                db.select(func.count(GameSession.session_id)).where(GameSession.result == "Won")
            ),
        }
        recent_sessions = (
            db.session.execute(
                db.select(GameSession)
                .order_by(GameSession.start_time.desc())
                .limit(5)
            )
            .scalars()
            .all()
        )
        return render_template("index.html", db_ok=True, stats=stats, recent_sessions=recent_sessions)

    @app.errorhandler(404)
    def not_found(error):
        return render_template("error.html", title="Page not found", message="The requested page does not exist."), 404

    @app.errorhandler(SQLAlchemyError)
    def database_error(error):
        db.session.rollback()
        return render_template("error.html", title="Database error", message=str(error)), 500

    @app.errorhandler(Exception)
    def application_error(error):
        return render_template("error.html", title="Application error", message=str(error)), 500

    return app


app = create_app()


if __name__ == "__main__":
    app.run(debug=True, port=5001)
