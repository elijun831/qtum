#!/bin/bash

# ================ Start Nginx ================
echo "[INFO] Starting Nginx in foreground mode..."
nginx -g "daemon off;" &
NGINX_PID=$!

# ================ Activate Virtual Environment ================
echo "[INFO] Activating Python virtual environment ($VIRTUAL_ENV)..."
. $VIRTUAL_ENV/bin/activate

# ================ Start JupyterLab ================
echo "[INFO] Starting JupyterLab..."
pipenv run jupyter lab --notebook-dir=$NOTEBOOKS_DIRECTORY --ip=0.0.0.0 --port=8888 --no-browser --allow-root &
JUPYTER_PID=$!
