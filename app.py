from flask import Flask, render_template, request
from models import db, Crop

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

with app.app_context():
    db.create_all()

@app.route('/')
def index():
    q = request.args.get('q', '')
    crops = Crop.query.filter(Crop.name.ilike(f'%{q}%')).all() if q else Crop.query.all()
    return render_template('index.html', crops=crops, q=q)

@app.route('/crop/<int:crop_id>')
def crop_detail(crop_id):
    crop = Crop.query.get_or_404(crop_id)
    return render_template('crop.html', crop=crop)

@app.route('/estimate', methods=['POST'])
def estimate():
    crop_id = int(request.form['crop_id'])
    area = float(request.form['area'])
    crop = Crop.query.get_or_404(crop_id)
    estimated = area * (crop.avg_yield or 0)
    return render_template('estimate.html', crop=crop, area=area, estimated=estimated)

if __name__ == '__main__':
    app.run(debug=True)
