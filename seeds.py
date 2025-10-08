import pandas as pd
from app import app
from models import db, Crop

df = pd.read_csv('data/crops.csv')

with app.app_context():
    for _, r in df.iterrows():
        crop = Crop(
            name=r['name'],
            season=r['season'],
            soil=r['soil'],
            ph_min=r['ph_min'],
            ph_max=r['ph_max'],
            avg_yield=r['avg_yield'],
            notes=r.get('notes', '')
        )
        db.session.add(crop)
    db.session.commit()

print("✅ Database seeded successfully!")
