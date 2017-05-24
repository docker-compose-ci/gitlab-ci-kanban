#start gitlab
cd gitlab
docker-compose restart

#start kanban
cd ../kanban
docker-compose restart

#start gitlab-ci-runner
gitlab-runner restart
