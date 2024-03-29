#!/bin/bash

# Start Nginx
envsubst < /app/nginx.conf > /etc/nginx/nginx.conf
nginx &

# Activate virtual environment
. /venv/bin/activate

# Start JupyterLab
pipenv run jupyter lab --notebook-dir=/notebooks --ip=0.0.0.0 --port=8888 --no-browser --allow-root &
