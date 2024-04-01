#!/bin/bash

set -e  # Exit script on error

# ================ Environment Variables ================
# Add or modify as needed, set default values here
export VIRTUAL_ENV="/venv"
export NOTEBOOKS_DIRECTORY="/notebooks"
export NGINX_CONF_FILE="./nginx.conf"

# ================ Validations ================
# Check if Nginx configuration file exists
if [[ ! -f $NGINX_CONF_FILE ]]; then
  echo "[ERROR] Nginx configuration file ($NGINX_CONF_FILE) not found." >&2
  exit 1
fi

# Check if Virtual Environment directory exists
if [[ ! -d $VIRTUAL_ENV ]]; then
  echo "[ERROR] Virtual environment directory ($VIRTUAL_ENV) not found." >&2
  exit 1
fi

# Check if JupyterLab notebooks directory exists
if [[ ! -d $NOTEBOOKS_DIRECTORY ]]; then
  echo "[ERROR] JupyterLab notebooks directory ($NOTEBOOKS_DIRECTORY) not found." >&2
  exit 1
fi

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

# ================ Graceful Shutdown ================
# Cleanup resources on script exit (EXIT) or signal reception
function cleanup() {
  echo "[INFO] Received shutdown signal. Cleaning up..."
  kill -TERM $NGINX_PID $JUPYTER_PID
  wait $NGINX_PID $JUPYTER_PID
  echo "[INFO] Nginx and JupyterLab stopped."
  exit 0
}

trap cleanup EXIT INT TERM

# ================ Main Execution Loop ================
echo "[INFO] Container startup complete. Ready to serve requests."

# Infinite loop to handle SIGINT, SIGTERM signals
while true; do
  sleep 1 &
  wait $!
done
