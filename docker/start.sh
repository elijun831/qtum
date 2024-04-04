#!/bin/bash

# ================ Start Services in Background ================
echo "[INFO] Starting Prometheus..."
# Start Prometheus in the background (adjust the command as needed)
/etc/prometheus/prometheus.yaml --config.file=/etc/prometheus/prometheus.yaml &

echo "[INFO] Starting Elasticsearch..."
# Start Elasticsearch in the background (adjust the command as needed)
/etc/elasticsearch/elasticsearch.yaml &

echo "[INFO] Starting Kibana..."
# Start Kibana in the background (adjust the command as needed)
/etc/kibana/kibana.yaml &

echo "[INFO] Starting Fluentd..."
# Start Fluentd in the background (adjust the command as needed)
/etc/td-agent/fluentd.conf -c /etc/td-agent/fluentd.conf &

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
