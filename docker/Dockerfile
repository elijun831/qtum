# Version 2.0.1
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
    python3-pip \
    python3-venv \
    build-essential \
    curl \
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

# Upgrade pip
RUN pip3 install --upgrade pip

# Install pipenv
RUN pip3 install pipenv

# Set up work directory
WORKDIR /app

# Copy Pipfile and Pipfile.lock
COPY Pipfile Pipfile.lock /app/

# Install dependencies using pipenv
RUN pipenv install --deploy

# Get the path of the pipenv virtual environment and store it in an environment variable
RUN pipenv --venv > venv_path
RUN echo "export PIPENV_VENV_PATH=$(pipenv --venv)" > ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# Switch the default shell to bash
SHELL ["/bin/bash", "-c"]

# Add the pipenv virtual environment to the PATH
ENV PATH=$PATH:/root/.local/share/virtualenvs/app-*/bin

# Expose port for Jupyter Notebook and debugging
EXPOSE 8888
EXPOSE 5678

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

