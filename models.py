from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Crop(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    season = db.Column(db.String(50))
    soil = db.Column(db.String(100))
    ph_min = db.Column(db.Float)
    ph_max = db.Column(db.Float)
    avg_yield = db.Column(db.Float)  # tonnes/hectare
    notes = db.Column(db.Text)
