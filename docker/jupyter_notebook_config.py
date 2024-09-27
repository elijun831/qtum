# Common settings for both Jupyter Notebook and JupyterLab
c.NotebookApp.token = ''
# c.NotebookApp.password = ''  # Commented out to leave the password blank
c.NotebookApp.allow_root = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.allow_origin = '*'
c.NotebookApp.open_browser = False
c.ServerApp.trust_xheaders = True

# Settings for JupyterLab
c.ServerApp.jpserver_extensions = {
    'jupyterlab': True,
    'other_extension': True,
}

# Enable WebSocket with SSL
c.NotebookApp.websocket_url = 'wss://127.0.0.1:8888'
c.NotebookApp.base_url = '/'

# Adjust Content-Security-Policy for secure WebSocket connection
c.NotebookApp.webapp_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors * 'self';"
    }
}

# SSL/TLS settings
c.NotebookApp.allow_origin = 'https://*.quantumworkspace.dev'
c.NotebookApp.allow_origin_pat = 'https://.*.quantumworkspace.dev'
c.NotebookApp.disable_check_xsrf = True
