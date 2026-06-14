from flask import Flask, jsonify, render_template_string
import socket
import os
import datetime

app = Flask(__name__)

WELCOME_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Docker Demo App</title>
    <style>
        body { font-family: sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        pre { background: #f4f4f4; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This app is running inside a Docker container.</p>
    <pre>
Hostname: {{ hostname }}
Version:  {{ version }}
Uptime:   3 days (since container boot)
    </pre>
    <p>Try the <a href="/api/info">/api/info</a> API endpoint.</p>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(
        WELCOME_HTML,
        hostname=socket.gethostname(),
        version=os.environ.get('APP_VERSION', 'dev')
    )

@app.route('/api/info')
def api_info():
    return jsonify({
        'app': 'docker-demo',
        'version': os.environ.get('APP_VERSION', 'dev'),
        'hostname': socket.gethostname(),
        'time': datetime.datetime.utcnow().isoformat() + 'Z',
        'python_version': os.environ.get('PYTHON_VERSION', 'unknown'),
        'message': 'If you see this, your Docker setup is working!'
    })

@app.route('/api/echo')
def api_echo():
    msg = os.environ.get('ECHO_MSG', 'No message provided')
    return jsonify({
        'echo': msg,
        'time': datetime.datetime.utcnow().isoformat() + 'Z'
    })

if __name__ == '__main__':
    port = int(os.environ.get('APP_PORT', 5000))
    app.run(host='0.0.0.0', port=port)
