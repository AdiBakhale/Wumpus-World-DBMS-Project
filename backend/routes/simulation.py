from flask import Blueprint, render_template, jsonify
from sqlalchemy import text
from database import db

simulation_bp = Blueprint("simulation", __name__)


@simulation_bp.route("/simulation")
def simulation():
    return render_template("simulation.html")


@simulation_bp.route("/api/simulation/<int:session_id>")
def simulation_data(session_id):

    query = text("""
        SELECT
            gs.step_number,
            c.row_number,
            c.column_number,
            at.action_name,
            gs.direction_facing,
            gs.score_after_step,

            STRING_AGG(pt.perception_name, ',') AS perceptions

        FROM game_steps gs

        JOIN cells c
            ON gs.cell_id = c.cell_id

        JOIN action_types at
            ON gs.action_type_id = at.action_type_id

        LEFT JOIN step_perceptions sp
            ON gs.step_id = sp.step_id

        LEFT JOIN perception_types pt
            ON sp.perception_type_id = pt.perception_type_id

        WHERE gs.session_id = :session_id

        GROUP BY
            gs.step_number,
            c.row_number,
            c.column_number,
            at.action_name,
            gs.direction_facing,
            gs.score_after_step

        ORDER BY gs.step_number;
    """)

    rows = db.session.execute(
        query,
        {"session_id": session_id}
    ).mappings()

    data = []

    for row in rows:

        perceptions = []

        if row["perceptions"]:

            perceptions = row["perceptions"].split(",")

        data.append({

            "step": row["step_number"],

            "row": row["row_number"] - 1,

            "col": row["column_number"] - 1,

            "score": row["score_after_step"],

            "direction": row["direction_facing"],

            "action": row["action_name"],

            "perceptions": perceptions

        })

    return jsonify(data)