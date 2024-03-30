#!/bin/bash

# Start Nginx
envsubst < ./nginx.conf > /etc/nginx/nginx.conf
nginx -g "daemon off;" &

# Activate virtual environment
. /venv/bin/activate

# Start JupyterLab
pipenv run jupyter lab --notebook-dir=/notebooks --ip=0.0.0.0 --port=80 --no-browser --allow-root &
