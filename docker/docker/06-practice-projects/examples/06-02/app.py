import os
import time
from flask import Flask, jsonify

app = Flask(__name__)

# 从环境变量读取配置，提供合理的默认值
APP_NAME = os.environ.get("APP_NAME", "Flask Docker Demo")
DEBUG = os.environ.get("FLASK_DEBUG", "0") == "1"


@app.route("/")
def index():
    return jsonify({
        "app": APP_NAME,
        "message": "Hello from Flask in Docker!",
    })


@app.route("/health")
def health():
    return jsonify({"status": "ok"})


@app.route("/slow")
def slow():
    """模拟耗时操作，验证多 worker 的必要性"""
    time.sleep(3)
    return jsonify({"result": "done after 3 seconds"})


if __name__ == "__main__":
    # Flask 内置服务器，仅用于本地开发
    app.run(host="0.0.0.0", port=5000, debug=DEBUG)
