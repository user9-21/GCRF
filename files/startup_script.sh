#!/bin/bash
sudo wget https://golang.org/dl/go1.16.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz

curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh 
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh 
sudo bash add-monitoring-agent-repo.sh 
sudo bash add-logging-agent-repo.sh 

sudo apt-get -y update
sudo apt-get -y install git
sudo apt-get install -y stackdriver-agent
sudo service stackdriver-agent start

mkdir /work
mkdir /work/go
mkdir /work/go/cache

export GOPATH=/work/go
export GOCACHE=/work/go/cache
export PATH=$PATH:/usr/local/go/bin

# Install Video queue Go source code
cd /work/go
mkdir video
gsutil cp gs://spls/gsp338/video_queue/main.go /work/go/video/main.go

# Get Cloud Monitoring (stackdriver) modules
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver

# Configure env vars for the Video Queue processing application
export MY_PROJECT_ID=REPLACE_WITH_PROJECT_ID
export MY_GCE_INSTANCE_ID=REPLACE_WITH_INSTANCE_ID
export MY_GCE_INSTANCE_ZONE=REPLACE_WITH_INSTANCE_ZONE

# Initialize and run the Go application
cd /work
go mod init go/video/main
go mod tidy
go run /work/go/video/main.go
