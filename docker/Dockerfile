# Version 3.0.0
# Base image
FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

# Install, configure, and start NTP service 
COPY ntp.conf /etc/ntp.conf
EXPOSE 123/udp
CMD ["ntpd", "-d"]

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
   default-jre \
   ecj \
   openjdk-8-jre-headless \
   openjdk-17-jre-headless \
   openjdk-11-jre-headless \
   openjdk-18-jre-headless \
   gnupg2 \
   && apt-get clean

# Create the 'elasticsearch' user if it doesn't already exist and add it to the 'elasticsearch' group.
RUN if ! grep -q '^elasticsearch:' /etc/group; then groupadd -r elasticsearch; fi && \
  if ! id -u elasticsearch > /dev/null 2>&1; then useradd -r -g elasticsearch elasticsearch; fi

# Set up default OpenJDK version to Java 18
ENV JAVA_HOME=/usr/lib/jvm/java-18-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
RUN java -version \
   && touch /etc/elasticsearch/jvm.options.d/set-java-home.options
COPY set-java-home.options /etc/elasticsearch/jvm.options.d/set-java-home.options
RUN chown -R elasticsearch:elasticsearch /etc/elasticsearch/jvm.options.d

# ==========================================
# Install Rust, update it, create a directory, and set the working directory to the new Rust application directory
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    $HOME/.cargo/bin/rustup update
ENV PATH="/root/.cargo/bin:${PATH}"
ENV PROJECT_DIR /usr/local/src/webapp
RUN mkdir -p ${PROJECT_DIR}/rust
WORKDIR ${PROJECT_DIR}/rust

# Install wasm-pack
RUN cargo install wasm-pack

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

# ==========================================
# Generate and modify Jupyter Notebook config
RUN . /venv/bin/activate && jupyter notebook --generate-config -y \
    && mkdir -p /home/appuser/.jupyter && echo "c.NotebookApp.token = ''" >> /home/appuser/.jupyter/jupyter_notebook_config.py

# Create a directory to store the certificates (OpenSSL certificate & dhparam)
# Copy domains.ext for use in Nginx and certificate generation 
RUN mkdir -p /etc/nginx/certs
COPY domains.ext /etc/nginx/certs/domains.ext
WORKDIR /etc/nginx/certs
COPY generate_certs.sh /etc/nginx/certs/generate_certs.sh
RUN chmod +x /etc/nginx/certs/generate_certs.sh \
  && /etc/nginx/certs/generate_certs.sh
  
# ==========================================
# Install Nginx and configure Nginx.conf
RUN apt-get update && apt-get install -y ca-certificates lsb-release ubuntu-keyring \
   && curl -s https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
   && gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg \
   && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
   http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" \
   | tee /etc/apt/sources.list.d/nginx.list \
   && apt-get update && apt-get install -y nginx \
   && rm /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/conf.d/jupyter.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN if ! grep -q '^nginx:' /etc/group; then groupadd -r nginx; fi && \
    if ! id -u nginx >/dev/null 2>&1; then useradd -r -g nginx nginx; fi && \
    chmod 755 /etc/nginx && \
    chmod 755 /etc/nginx/* && \
    chown -R nginx:nginx /etc/nginx && \
    chmod 644 /etc/nginx/*.conf && \
    chmod 644 /etc/nginx/conf.d/*.conf

# CMD ["nginx", "-g", "daemon off;"]

# Create Nginx user and group; set permissions and ownership
RUN chown nginx:nginx /etc/nginx/certs/*.pem \
   && chmod 700 /etc/nginx/certs \
   && chmod 400 /etc/nginx/certs/*.pem \
   && chown nginx:nginx /etc/nginx/certs/*.key \
   && chmod 400 /etc/nginx/certs/*.key \
   && chown nginx:nginx /etc/nginx/certs/*.crt \
   && chmod 400 /etc/nginx/certs/*.crt

# ==========================================
# Expose Ports (Adjust as necessary) 
EXPOSE 8888 8889 5678 8080 443 8443 80 9090 24224 24225

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

# ==========================================

# Install and configure Elasticsearch
EXPOSE 9200 9300
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg \
  && apt-get update && apt-get install -y apt-transport-https \
  && echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list \
  && apt-get update && apt-get install -y elasticsearch \
  && GENERATED_PW=$(grep -oP '(?<=password for the elastic built-in superuser is : ).*' /var/log/elasticsearch/elasticsearch.log) \
  && echo "ES_JAVA_OPTS=-Des.password=$GENERATED_PW" >> /etc/default/elasticsearch

# Create keystore password file if needed
RUN if [ -f /var/log/elasticsearch/my_pwd_file.tmp ]; then \
        echo "keystore_password" > /var/log/elasticsearch/my_pwd_file.tmp; \
        chmod 600 /var/log/elasticsearch/my_pwd_file.tmp; \
    fi

# Systemd Environment File and Start Elasticsearch
RUN echo "ES_JAVA_OPTS=-Des.password=$GENERATED_PW" > /etc/systemd/system/elasticsearch.service.d/env_file.conf \
    && echo "ES_KEYSTORE_PASSPHRASE_FILE=/var/log/elasticsearch/my_pwd_file.tmp" >> /etc/systemd/system/elasticsearch.service.d/env_file.conf \ 
RUN echo "keystore_password" > /var/log/elasticsearch/my_pwd_file.tmp \
  && chmod 600 /var/log/elasticsearch/my_pwd_file.tmp \
  && systemctl set-environment ES_KEYSTORE_PASSPHRASE_FILE=/var/log/elasticsearch/my_pwd_file.tmp \
  && chown elasticsearch:elasticsearch -R /var/log/elasticsearch \
  && chmod 775 /var/log/elasticsearch

# Copy Elasticsearch-related files to directories and change ownderships to the Elasticsearch group
COPY elasticsearch.service /usr/lib/systemd/system/elasticsearch.service
COPY elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
COPY elasticsearch /etc/default/elasticsearch
RUN chown elasticsearch:elasticsearch -R /var/lib/elasticsearch \
  && chmod 775 /var/lib/elasticsearch \
  && chown elasticsearch:elasticsearch -R /etc/default/elasticsearch \
  && chmod 775 /etc/default/elasticsearch \
  && chown elasticsearch:elasticsearch -R /etc/elasticsearch \
  && chmod 775 /etc/elasticsearch

# Set ownership and environment and expose ports
RUN chown elasticsearch:elasticsearch -R /usr/share/elasticsearch \
  && chmod 775 /usr/share/elasticsearch
ENV ES_HOME=/usr/share/elasticsearch 
CMD ["/usr/share/elasticsearch/bin/elasticsearch", "-Des.path.home=$ES_HOME"] 

# Run Elasticsearch
RUN /bin/systemctl daemon-reload \
  && /bin/systemctl enable elasticsearch.service \
  && /bin/systemctl start elasticsearch.service

# Create directory for Elasticsearch data
USER root 
RUN mkdir -p /mnt/data/elasticsearch \
  && chown 1000:1000 /mnt/data/elasticsearch 

# ==========================================

# Install and start Kibana
EXPOSE 5601
RUN apt-get update && apt-get install kibana \
   && /bin/systemctl daemon-reload \
   && /bin/systemctl enable kibana.service \
   && systemctl start kibana.service 
COPY kibana.yml /etc/kibana/kibana.yml
RUN systemctl restart kibana.service 

# Conditional group and user creation 
RUN if ! grep -q '^kibana:' /etc/group; then groupadd -r kibana; fi && \
    if ! id -u kibana > /dev/null 2>&1; then useradd -r -g kibana kibana; fi && \
    chown kibana:kibana /etc/kibana/kibana.yml && \
    chmod 700 /etc/kibana/kibana.yml
CMD ["/usr/share/kibana/bin/kibana", "-c", "/etc/kibana/kibana.yml"]

# ==========================================

# Install and start Logstash
# Install and start Kibana
EXPOSE 5044
RUN apt-get update && apt-get install logstash \
   && systemctl start logstash.service \
   && touch /etc/logstash/conf.d/logstash.yml
COPY logstash.yml /etc/logstash/conf.d/logstash.yml
RUN systemctl restart kibana.service 

# ==========================================
# Configure ElasticSearch, Logstash, Kibana, and Nginx and start processes with it 
COPY start.sh /start.sh
ENTRYPOINT ["/bin/bash", "/start.sh"]
