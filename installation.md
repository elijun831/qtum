# Required Installations #

Just copy and past the following into your terminal on your computer or your Linux virtual machine.

## Python 3.11.8 ##
```
sudo apt update && sudo apt upgrade -y
sudo apt update && sudo apt install software-properties-common build-essential libffi-dev libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev libffi-dev libssl-dev libsqlite3-dev wget libbz2-dev pkg-config
wget https://www.python.org/ftp/python/3.11.8/Python-3.11.8.tgz
tar xvf Python-3.11.8.tgz
cd Python-3.11.8
./configure 
--enable-optimizations
sudo make altinstall
python3.11 --version
```

## Download Pipenv and go to a Pipenv shell ##
```
python3.11 -m pipenv shell
python3.11 -m pip install --user pipenv
python3.11 -m pipenv shell
```

## Docker ##
```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
```

## Microk8s ##
```
sudo snap install microk8s --classic
sudo ufw allow in on cni0 && sudo ufw allow out on cni0
sudo ufw default allow routed
sudo microk8s enable dns 
sudo microk8s enable dashboard
sudo microk8s enable storage
sudo microk8s start
```

## Helm ##
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
