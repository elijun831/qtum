# Version 3.0.0
# Base image
FROM ubuntu:latest

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

# Install mkcert and generate SSL certificate
RUN mkdir -p /etc/nginx/certs && \
    apt-get update && \
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && \
    chmod +x mkcert-v*-linux-amd64 && \
    mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert && \
    mkcert -install && \
    mkcert -CAROOT -cert-file /etc/nginx/certs/mkcert-ca.pem  -key-file /etc/nginx/certs/mkcert-ca-key.pem && \
    mkcert -cert-file /etc/nginx/certs/_wildcard.quantumworkspace.dev+3.pem -key-file /etc/nginx/certs/_wildcard.quantumworkspace.dev+3-key.pem "*.quantumworkspace.dev" localhost 127.0.0.1 ::1

# Create Nginx user and group
RUN groupadd -r nginx && useradd -r -g nginx nginx

# Setting permissions and ownership
RUN chown nginx:nginx /etc/nginx/certs/*.pem && \
    chmod 600 /etc/nginx/certs/*.pem

# Remove default Nginx configuration
RUN rm /etc/nginx/sites-enabled/default

# Expose ports
EXPOSE 8888
EXPOSE 5678
EXPOSE 8080
EXPOSE 443
EXPOSE 80
EXPOSE 22
EXPOSE 53
EXPOSE 68

# Copy the main Nginx configuration file
# COPY ./nginx.conf /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# Create non-root user for security
RUN adduser -u 5678 --disabled-password --gecos "" appuser

# Create notebooks directory
RUN mkdir -p /notebooks

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
