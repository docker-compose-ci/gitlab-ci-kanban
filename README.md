# gitlab-ci-kanban 基于docker快速部署CI框架(gitlab、gitlab-ci-runner、kanban)

## 本项目的目的

- 代码管理-gitlab
- 敏捷管理-kanban
- 持续集成-gitlab-ci-runner（docker提供无污染的集成环境），可自由扩展到devop
- 快速搭建-docker-compose

## 部署方法

### 设置host
机器设置host，追加“127.0.0.1 code”，非本机需要使用局域网或外网ip，如果不想使用“code”可以自由更换，但是要注意同时在gitlab、kanban和runner的配置中做相应的改动

```
#for ubuntu
echo "127.0.0.1 code" >>> /etc/hosts
```

### 安装软件

docker,docker-compose,gitlab-ci-multi-runner

```
chmod +x install-software-ubuntu.sh
./install-software-ubuntu.sh
```

### 获取docker宿主ip

ifconfig，找到docker0网卡的ip并记录

<image src="https://github.com/postor/gitlab-ci-kanban/raw/master/images/ip.png">


### 启动gitlab并配置ci和kanban

#### 启动gitlab

启动gitlab

```
cd gitlab
docker-compose up -d
```

访问 http://code/ 更改密码

#### 配置gitlab-ci

运行注册
```
gitlab-ci-multi-runner register
#url填写http://code/，gitlab的网址
#token 授权码来自http://code/admin/runners
#名字，描述，标签，随便填，看需要
#executor 这里我用docker，最简单的是shell，看自己爱好
#其他自己看着填
```
修改配置 `vi /etc/gitlab-runner/config.toml` 找到 `[runners.docker]` 追加 `extra_hosts = ["code:172.17.0.1"]`
```
concurrent = 1
check_interval = 0

[[runners]]
  name = "code1"
  url = "http://code/"
  token = "your token"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "ubuntu"
    privileged = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
    extra_hosts = ["code:172.17.0.1"]
  [runners.cache]
```

测试启动runner

```
gitlab-runner start
```

#### 配置kanban

打开应用管理，http://code/admin/applications ，回调授权填写 `http://code:7080/assets/html/user/views/oauth.html` 并勾选授权

<image src="https://github.com/postor/gitlab-ci-kanban/raw/master/images/kanban.png">

在kanban/docker-composer.yml中填写刚刚创建应用得到的appid和key，并找到 `extra_hosts`并将code映射ip到宿主ip，

```
kanban:
  image: leanlabs/kanban:1.7.1
  environment:
    # Your GitLab OAuth client ID
    - KANBAN_GITLAB_CLIENT=your app id
    # Your GitLab OAuth client secret key
    - KANBAN_GITLAB_SECRET=your secret key
  extra_hosts:
    - "code:172.17.0.1"
```

启动kanban

```
cd kanban
docker-compose up -d
```

### 一键启动

```
chmod +x start-service.sh
./start-service.sh
```

### 备份恢复

找到文件保存的位置

```
docker volume list
# 我这里是gitlab_data

docker volume inspect gitlab_data
# "Mountpoint": "/var/lib/docker/volumes/gitlab_data/_data"

# 进入目录
cd /var/lib/docker/volumes/gitlab_data/_data/backups
ls
# empty

# 找到gitlab的container
docker ps
# 我这里别名是gitlab_gitlab_1

# 执行备份
docker exec -t gitlab_gitlab_1  gitlab-rake gitlab:backup:create
ls
# xxx.tar
```

恢复需要停服务，在 `docker exec -it gitlab_gitlab_1 bash` 中运行
```
service gitlab stop
gitlab-rake gitlab:backup:restore BACKUP=1493107454_2017_04_25_9.1.0
service gitlab start
```


