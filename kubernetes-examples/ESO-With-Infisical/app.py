import os
from flask import Flask, render_template

app = Flask(__name__)

SECRET_KEYS = [
    "DB_HOST",
    "DB_PORT",
    "DB_USERNAME",
    "DB_PASSWORD",
    "API_KEY",
]


@app.route("/")
def index():
    secrets = {}
    for key in SECRET_KEYS:
        value = os.environ.get(key)
        secrets[key] = value
    return render_template("index.html", secrets=secrets)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
