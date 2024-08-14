import flask
from flask import Flask, render_template, request, redirect, jsonify, render_template_string
import subprocess
import os

# Intern routes

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route('/pod-info')
def get_server_info():
    hostname = os.popen('hostname').read().strip().lower()
    date_command = 'date +"%Y-%m-%d %H:%M:%S"'
    last_updated = os.popen(date_command).read().strip().lower()
    response = f"hostname:{hostname} - up at {last_updated}"
    return response

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port="5000")
