#!/bin/bash

#  powered by HowHowWen

arg1=$1
arg2=$2
arg3=$3
arg4=$4
_version="1.1.0"



function log_info() {
  DATE=$(date "+%Y-%m-%d %H:%M:%S")
  echo -e "\033[32m$DATE [INFO]: $1 \033[0m"
}

function log_err() {
  DATE=$(date "+%Y-%m-%d %H:%M:%S")
  echo -e "\033[31m$DATE [ERROR]: $1 \033[0m"
}


function init_env(){
    sudo timedatectl set-timezone Asia/Taipei
    sudo useradd ubuntu -m -s /bin/bash  2>/dev/null
    [[ -n $arg4 ]] && echo $arg4 >> /home/ubuntu/.ssh/authorized_keys
    log_info "Init DONE ..." >> /tmp/startup.log
}


function install_docker_packages(){
    log_info "Installing Package" >> /tmp/startup.log
    sudo apt update && sudo apt install docker.io docker-compose -y
    sudo usermod -aG docker ubuntu
    log_info "Package Installed..." >> /tmp/startup.log
}

function setup_container(){
    log_info "Getting APP..." >> /tmp/startup.log
    source /etc/profile
    git  -C /home/ubuntu/ clone https://gitlab.com/tgc101-tw/tgc101.git
    [[ -n $arg2 ]] && cd /home/ubuntu/tgc101 && bash initDB.sh $arg2
    cd /home/ubuntu/tgc101 && sudo docker-compose -f  $arg1 up -d 
     [[ "$?" != "0" ]] && log_err "Start App ERROR ...." 
    log_info "APP Started ..." >> /tmp/startup.log
}

function ci_cd(){
    log_info "CI/CD init .." >> /tmp/startup.log
    sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
    sudo chmod +x /usr/local/bin/gitlab-runner
    sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
    sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    sudo gitlab-runner start
    sudo gitlab-runner register --non-interactive  --url https://gitlab.com/ --registration-token $arg3  --executor "shell" --description "lab-tgc101-${HOSTNAME}" --tag-list "ubuntu2004-lab"
    sudo rm -rf /home/gitlab-runner/.bash_logout
    sudo usermod -aG ubuntu gitlab-runner
    sudo usermod -aG root gitlab-runner
    sudo chmod -R g=rwx /home/ubuntu
    sudo chmod o+xw /home/ubuntu/tgc101/docker-volume/html/
    log_info "CI/CD DONE.." >> /tmp/startup.log
}



function run(){
    init_env
    install_docker_packages
    setup_container
    [[ -n $arg3 ]] && ci_cd
}



run

