# Version 3.0.0
# Base image
FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive

# Copy custom hosts file to /etc/hosts
COPY hosts /etc/hosts

# Set environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-apt \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-distutils \
    binutils \
    build-essential \
    curl \
    vim \
    vim-common \
    vim-runtime \
    nano \
    flameshot \
    keepassxc \
    bleachbit \
    nodejs \
    g++ \
    git \
    libblas-dev \
    libffi-dev \
    liblapack-dev \
    libssl-dev \
    texlive-latex-base \
    latexmk \
    make \
    wget \
    zlib1g-dev \
    bash \
    tree \
    nginx \
    libnss3-tools \
    prometheus \
    td-agent \
    elasticsearch \
    kibana \
    && apt-get clean

# Install Rust, update it, create a directory, and set the working directory to the new Rust application directory
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    $HOME/.cargo/bin/rustup update
ENV PATH="/root/.cargo/bin:${PATH}"
ENV PROJECT_DIR /usr/local/src/webapp
RUN mkdir -p ${PROJECT_DIR}/rust
WORKDIR ${PROJECT_DIR}/rust

# Install wasm-pack
RUN cargo install wasm-pack

# Configure Prometheus
RUN mkdir -p /etc/prometheus
COPY prometheus.yml /etc/prometheus/prometheus.yml
RUN chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Configure Fluentd
RUN mkdir -p /etc/td-agent
COPY fluentd.conf /etc/td-agent/fluentd.conf
RUN chown td-agent:td-agent /etc/td-agent/fluentd.conf

# Configure ElasticSearch
RUN mkdir -p /etc/elasticsearch
COPY elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
RUN chown elasticsearch:elasticsearch /etc/elasticsearch/elasticsearch.yml

# Configure Kibana
RUN mkdir -p /etc/kibana
COPY kibana.yml /etc/kibana/kibana.yml
RUN chown kibana:kibana /etc/kibana/kibana.yml

# Set up work directory for Python application
WORKDIR /home/appuser/app

# Copy Pipfile and Pipfile.lock
COPY Pipfile Pipfile.lock /home/appuser/app/

# Create and activate the virtual environment
RUN python3.11 -m venv /venv
ENV PATH="/venv/bin:${PATH}"
RUN . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install pipenv

# Install dependencies using pipenv
RUN PIPENV_IGNORE_VIRTUALENVS=1 . /venv/bin/activate && pipenv install --deploy

# Install Jupyter within the virtual environment
RUN . /venv/bin/activate && pipenv run pip install jupyter notebook jupyterlab voila

# Copy pre-configured Jupyter Notebook config
COPY jupyter_notebook_config.py /home/appuser/.jupyter/jupyter_notebook_config.py

# Generate Jupyter Notebook config
RUN . /venv/bin/activate && jupyter notebook --generate-config -y

# Modify Jupyter Notebook config
RUN mkdir -p /home/appuser/.jupyter && echo "c.NotebookApp.token = ''" >> /home/appuser/.jupyter/jupyter_notebook_config.py

# Create a directory to store the certificates
RUN mkdir -p /etc/nginx/certs

# OpenSSL certificate & dhparam generation script
WORKDIR /etc/nginx/certs  # Set the working directory for the commands

# Create the certificates directory if it doesn't exist
RUN mkdir -p /etc/nginx/certs

# Copy the script into the image
COPY generate_certs.sh /etc/nginx/certs/generate_certs.sh

# Make the script executable
RUN chmod +x /etc/nginx/certs/generate_certs.sh

# Execute the script
RUN /etc/nginx/certs/generate_certs.sh

# Create Nginx user and group 
RUN groupadd -r nginx && useradd -r -g nginx nginx

# Setting permissions and ownership
RUN chown nginx:nginx /etc/nginx/certs/*.pem && \
    chmod 600 /etc/nginx/certs/*.pem

RUN chown nginx:nginx /etc/nginx/certs/*.csr && \
    chmod 600 /etc/nginx/certs/*.csr

# Expose Ports (Adjust as necessary) 
EXPOSE 8888
EXPOSE 5678
EXPOSE 8080
EXPOSE 443
EXPOSE 80
EXPOSE 9090  # Prometheus
EXPOSE 9200  # Elasticsearch
EXPOSE 5601  # Kibana 
EXPOSE 24224 # Fluentd

# Remove default Nginx configuration
RUN rm /etc/nginx/sites-enabled/default

# Copy custom Nginx configuration to /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/conf.d/jupyter.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

# Set up work directory
WORKDIR /app

# Create a directory for notebooks
RUN mkdir -p /notebooks

# Specify the directory as a volume
VOLUME /notebooks

# Create non-root user for security
RUN adduser -u 5678 --disabled-password --gecos "" appuser

# Change ownership of the notebooks directory to appuser
RUN chown -R appuser:appuser /notebooks

# Copy startup script
COPY start.sh /start.sh

# Switch to root
USER root

# Change permissions of the directories to ensure appuser can write to them
RUN chmod -R 755 /app && chmod -R 755 /notebooks
RUN chmod +x /start.sh

# Start JupyterLab
ENTRYPOINT ["/bin/bash", "/start.sh"]
