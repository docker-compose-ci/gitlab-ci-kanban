# 安装docker
apt-get install docker.io

# 安装docker-compose
apt-get install docker-compose

# 安装gitlab-runner
curl -L https://packages.gitlab.com/install/repositories/runner/gab-ci-multi-runner/script.deb.sh | sudo bash
apt-get update
apt-get install gitlab-ci-multi-runner

