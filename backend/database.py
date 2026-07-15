from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError


db = SQLAlchemy()


def check_database_connection():
    try:
        db.session.execute(text("SELECT 1"))
        return True, "Database connection successful."
    except SQLAlchemyError as exc:
        db.session.rollback()
        return False, str(exc)
