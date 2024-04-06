# QuantumWorkspace - A Quantum-Ready Jupyter Environment

This repository provides a Dockerfile for creating a JupyterLab environment within a Pipenv virtual environment. 
It is equipped with Python packages tailored for quantum computing, including Qiskit, QSharp, and Amazon Braket. 
Built on the Ubuntu 22.04 version, this Dockerfile streamlines the setup process for quantum programming.

## Prerequisites

You should install Docker in your machine (https://docs.docker.com/desktop/).

## Getting Started

Follow these steps to get the environment up and running.

1. Clone the repository:
```
git clone https://github.com/elijun831/3.0.0-3
```

2. Navigate to the directory containing the Dockerfile by typing the following in your terminal:
```
cd quantumworkspace/docker
```

3. Build the Docker image:
```
(sudo) docker compose up -build
```

4. After running the Docker container, you should see a URL in the terminal output that looks like this:
```
http://localhost:8888/tree?token=[[token]]
## or
http://127.0.0.1:8888/tree?token=[[token]]
```
Copy the [[token]] and paste it in your Jupyter log-in webpage to access the JupyterLab server.
