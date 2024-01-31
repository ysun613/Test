
from flask import Flask, request, jsonify
import sqlite3
import datetime

app = Flask(__name__)
DATABASE = "punch_data.db"

def init_db():
    with app.app_context():
        db = get_db()
        sql = """
        DROP TABLE IF EXISTS punches;
CREATE TABLE punches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    weather TEXT,
    temperature REAL,
    ip_address TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
        """
        db.cursor().executescript(sql)
        db.commit()
        db.close()

def get_db():
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

# def close_db(e=None):
#     db = getattr(g, '_database', None)
#     if db is not None:
#         db.close()

@app.route('/get_ip', methods=['GET'])
def get_ip():
    client_ip = request.remote_addr
    data = {"client_ip":client_ip}
    return jsonify(data)

@app.route('/save_punch', methods=['POST'])
def save_punch():
    data = request.json
    name = data.get('name')
    weather = data.get('weather')
    temperature = data.get('temperature')
    ip_address = request.remote_addr

    timestamp = datetime.datetime.utcnow()

    try:
        db = get_db()
        db.execute("INSERT INTO punches (name, weather, temperature, ip_address, timestamp) VALUES (?, ?, ?, ?, ?)",
                   (name, weather, temperature, ip_address, timestamp))
        db.commit()
        db.close()
        return jsonify({"message": "Punch data saved successfully"})
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.config['DATABASE'] = DATABASE
    with app.app_context():
        init_db()
    app.run(debug=True,host = '0.0.0.0')
