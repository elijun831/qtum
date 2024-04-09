#!/bin/bash

# ================ Start Services in Background ================
echo "[INFO] Starting Elasticsearch..."
# Start Elasticsearch in the background (adjust the command as needed)
./elasticsearch.yaml &

echo "[INFO] Starting Fluentd..."
# Start Fluentd in the background (adjust the command as needed)
./fluentd.conf -c /etc/fluent-package/fluentd.conf &

echo "[INFO] Starting Kibana..."
# Start Kibana in the background (adjust the command as needed)
./kibana.yaml &

# ================ Start Nginx ================
echo "[INFO] Starting Nginx in foreground mode..."
nginx -g "daemon off;"

# ================ Activate Virtual Environment ================
echo "[INFO] Activating Python virtual environment..."
. /venv/bin/activate

# ================ Start JupyterLab ================
echo "[INFO] Starting JupyterLab..."
pipenv run jupyter lab --notebook-dir=/notebooks --ip=0.0.0.0 --port=8888 --no-browser --allow-root

# ================ Main Execution Loop ================
echo "[INFO] Container startup complete. Ready to serve requests."

# Infinite loop to handle SIGINT, SIGTERM signals
while true; do
  sleep 1 &
  wait $!
done
