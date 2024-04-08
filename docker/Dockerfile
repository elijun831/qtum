# Version 3.0.0
# Base image
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Copy configuration files
COPY hosts /etc/hosts
COPY limits.conf /etc/security/limits.conf
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

# Install and configure Supervisord
RUN apt-get update && apt-get install supervisor \
    && mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install, configure, and start Kibana
RUN wget -q https://artifacts.elastic.co/downloads/kibana/kibana-8.13.1-amd64.deb \
    && wget -q https://artifacts.elastic.co/downloads/kibana/kibana-8.13.1-amd64.deb.sha512 \
    && sha512sum -c kibana-8.13.1-amd64.deb.sha512 \
    && dpkg -i kibana-8.13.1-amd64.deb \
    && rm kibana-8.13.1-amd64.deb
COPY kibana.yaml /etc/kibana/kibana.yaml
EXPOSE 5601
CMD ["/usr/share/kibana/bin/kibana", "-c", "/etc/kibana/kibana.yaml"]

# Install, configure, and start NTP service 
COPY ntp.conf /etc/ntp.conf
EXPOSE 123/udp
CMD ["ntpd", "-d"]

# Install and configure Fluentd
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
USER root
RUN mkdir -p /mnt/data/elasticsearch \
    && chown 1000:1000 /mnt/data/elasticsearch

# Set up work directory for Python application, copy Pipfile and Pipfile.lock, amd create and activate the virtual environment
WORKDIR /home/appuser/app
COPY Pipfile Pipfile.lock /home/appuser/app/
RUN python3.11 -m venv /venv
ENV PATH="/venv/bin:${PATH}"
RUN . /venv/bin/activate \
    && pip install --upgrade pip \
    && pip install pipenv
RUN PIPENV_IGNORE_VIRTUALENVS=1 . /venv/bin/activate \
    && pipenv install --deploy
RUN . /venv/bin/activate \
    && pipenv run pip install jupyter notebook jupyterlab voila
COPY jupyter_notebook_config.py /home/appuser/.jupyter/jupyter_notebook_config.py

# Generate and modify Jupyter Notebook config
RUN . /venv/bin/activate && jupyter notebook --generate-config -y \
    && mkdir -p /home/appuser/.jupyter && echo "c.NotebookApp.token = ''" >> /home/appuser/.jupyter/jupyter_notebook_config.py

# Create a directory to store the certificates (OpenSSL certificate & dhparam)
RUN mkdir -p /etc/nginx/certs
WORKDIR /etc/nginx/certs
COPY generate_certs.sh /etc/nginx/certs/generate_certs.sh
RUN chmod +x /etc/nginx/certs/generate_certs.sh \
    && /etc/nginx/certs/generate_certs.sh

# Set domains.ext as an environment variable
ENV DOMAINS_EXT domains.ext

# Nginx Installation and Configuration
RUN apt-get update && apt-get install -y nginx libnss3-tools \
    && rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/conf.d/jupyter.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

# Create Nginx user and group; set permissions and ownership
RUN groupadd -r nginx && useradd -r -g nginx nginx \
   && chown nginx:nginx /etc/nginx/certs/*.pem \
   && chmod 600 /etc/nginx/certs/*.pem \
   && chown nginx:nginx /etc/nginx/certs/*.csr \
   && chmod 600 /etc/nginx/certs/*.csr \
   && chown nginx:nginx /etc/nginx/certs/*.key \
   && chmod 600 /etc/nginx/certs/*.key \
   && chown nginx:nginx /etc/nginx/certs/*.crt \
   && chmod 600 /etc/nginx/certs/*.crt

# Expose Ports (Adjust as necessary) 
EXPOSE 8888 5678 8080 443 80 9090 9200 24224 24225

# Create non-root user for security
RUN adduser -u 5678 --disabled-password --gecos "" appuser
WORKDIR /notebooks
RUN mkdir -p /notebooks \
    && chown -R appuser:appuser /notebooks
USER root
COPY --chown=appuser:appuser . /notebooks
VOLUME /notebooks

# Set up work directory and ensure permissions
WORKDIR /app
RUN chmod -R 755 /app

# Configure Supervisord and start processes with it 
COPY start.sh /start.sh
ENTRYPOINT ["/bin/bash", "/start.sh"]
