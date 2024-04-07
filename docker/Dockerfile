# Version 3.0.0
# Base image
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Copy custom hosts file to /etc/hosts
COPY hosts /etc/hosts

# Copy limits.conf file to /etc/security/limits.conf
COPY limits.conf /etc/security/limits.conf

# Copy sysctl.conf file to /etc/sysctl.conf
COPY sysctl.conf /etc/sysctl.conf

# Set environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# Install necessary packages
RUN apt-get update && apt-get install -y \
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
   python3.11 \
   python3.11-venv \
   python3-apt \
   python3-pip \
   python3-setuptools \
   python3-wheel \
   python3-distutils \
   ruby \
   ruby-dev \
   ntpdate \
   ntpstat \
   supervisor \
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

# Install Supervisord, create supervisord configuration directory, and copy supervisord.conf file
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install Kibana package, verify checksum, and install Kibana
RUN wget -q https://artifacts.elastic.co/downloads/kibana/kibana-8.13.1-amd64.deb \
    && wget -q https://artifacts.elastic.co/downloads/kibana/kibana-8.13.1-amd64.deb.sha512 \
    && sha512sum -c kibana-8.13.1-amd64.deb.sha512 \
    && dpkg -i kibana-8.13.1-amd64.deb \
    && rm kibana-8.13.1-amd64.deb

# Copy Kibana configuration file and expose Kibana port (adjust as necessary)
COPY kibana.yaml /etc/kibana/kibana.yaml
EXPOSE 5601

# Start Kibana using the CMD directive
CMD ["/usr/share/kibana/bin/kibana", "-c", "/etc/kibana/kibana.yaml"]

# Copy ntp.conf to /etc/ntp.conf
COPY ntp.conf /etc/ntp.conf

# Expose NTP port
EXPOSE 123/udp

# Start NTP daemon
CMD ["ntpd", "-d"]

# Install Fluent-package and configure fluentd.conf
RUN curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-jammy-fluent-package5-lts.sh | sh \
   && DEBIAN_FRONTEND=noninteractive apt-get update \
   && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
   && groupadd -r fluent-package \
   && useradd -r -g fluent-package fluent-package \
   && mkdir -p /etc/fluent-package \
   && chown fluent-package:fluent-package /etc/fluent-package
COPY fluentd.conf /etc/fluent-package/fluentd.conf
RUN chown fluent-package:fluent-package /etc/fluent-package/fluentd.conf

# Create directory for Elasticsearch data
RUN mkdir -p /mnt/data/elasticsearch

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

# Create a directory to store the certificates (OpenSSL certificate & dhparam)
RUN mkdir -p /etc/nginx/certs
WORKDIR /etc/nginx/certs 

# Create the certificates directory if it doesn't exist; copy the script into the image
COPY generate_certs.sh /etc/nginx/certs/generate_certs.sh

# Make the script executable and execute the script
RUN chmod +x /etc/nginx/certs/generate_certs.sh \
    && /etc/nginx/certs/generate_certs.sh

# Create Nginx user and group; set permissions and ownership
RUN groupadd -r nginx && useradd -r -g nginx nginx \
   && chown nginx:nginx /etc/nginx/certs/*.pem \
   && chmod 600 /etc/nginx/certs/*.pem \
   && chown nginx:nginx /etc/nginx/certs/*.csr \
   && chmod 600 /etc/nginx/certs/*.csr

# Expose Ports (Adjust as necessary) 
EXPOSE 8888 5678 8080 443 80 9090 9200 24224 24225

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
