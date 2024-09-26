# Version 2.0.2
# Base image
FROM debian:latest

# Set environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# Install necessary packages
RUN apt-get update && apt-get install -y \
python3.11 \
build-essential \
curl \
vim \
vim-common \
vim-runtime \
nano \
flameshot \
keepassxc \
bleachbit \
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
&& apt-get clean

# Install Rust, update it, create a directory, and set the working directory to the new Rust application directory
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
$HOME/.cargo/bin/rustup update
ENV PATH="/root/.cargo/bin:${PATH}"
ENV PROJECT_DIR /usr/local/src/webapp
RUN mkdir -p ${PROJECT_DIR}/rust
WORKDIR ${PROJECT_DIR}/rust

# Install pipenv & upgrade pip
RUN pip install --upgrade pip
RUN pip install pipenv

# Set up work directory for Python application
WORKDIR /app

# Copy Pipfile and Pipfile.lock and install pipenv
COPY Pipfile Pipfile.lock /app/
RUN pipenv install --deploy

# Install Jupyter
RUN pipenv install jupyter notebook jupyterlab voila 

# Expose ports
EXPOSE 8888
EXPOSE 5678
EXPOSE 8080
EXPOSE 80

# Set up work directory
WORKDIR /app

# Create a directory for notebooks
RUN mkdir /notebooks

# Specify the directory as a volume
VOLUME /notebooks

# Create non-root user for security
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app

# Change ownership of the notebooks directory to appuser
RUN chown -R appuser:appuser /notebooks

# Switch to appuser
USER appuser

# Change permissions of the directories to ensure appuser can write to them
RUN chmod -R 755 /app && chmod -R 755 /notebooks

# Start JupyterLab
CMD ["pipenv", "run", "jupyter", "lab", "--notebook-dir=/notebooks", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
