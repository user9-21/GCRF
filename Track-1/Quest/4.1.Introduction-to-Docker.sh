curl -o default.sh https://raw.githubusercontent.com/user9-21/GoogleCloudReady-Facilitator-program/main/files/default.sh
source default.sh

docker run hello-world
docker images
docker run hello-world
docker ps
docker ps -a
mkdir test && cd test
cat > Dockerfile <<EOF
# Use an official Node runtime as the parent image
FROM node:lts
# Set the working directory in the container to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
ADD . /app
# Make the container's port 80 available to the outside world
EXPOSE 80
# Run app.js using node when the container launches
CMD ["node", "app.js"]
EOF
cat > app.js <<EOF
const http = require('http');
const hostname = '0.0.0.0';
const port = 80;
const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World\n');
});
server.listen(port, hostname, () => {
    console.log('Server running at http://%s:%s/', hostname, port);
});
process.on('SIGINT', function() {
    console.log('Caught interrupt signal and will exit');
    process.exit();
});
EOF
docker build -t node-app:0.1 .
docker images
docker run -p 4000:80 --name my-app node-app:0.1
curl http://localhost:4000
docker stop my-app && docker rm my-app
docker run -p 4000:80 --name my-app -d node-app:0.1
docker ps
#cd test
cat > app.js <<EOF
const http = require('http');
const hostname = '0.0.0.0';
const port = 80;
const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Welcome to Cloud\n');
});
server.listen(port, hostname, () => {
    console.log('Server running at http://%s:%s/', hostname, port);
});
process.on('SIGINT', function() {
    console.log('Caught interrupt signal and will exit');
    process.exit();
});
EOF
docker build -t node-app:0.2 .
docker run -p 8080:80 --name my-app-2 -d node-app:0.2
docker ps
curl http://localhost:8080
curl http://localhost:4000
docker tag node-app:0.2 gcr.io/$PROJECT_ID/node-app:0.2
docker images
docker push gcr.io/$PROJECT_ID/node-app:0.2
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker rmi node-app:0.2 gcr.io/$PROJECT_ID/node-app node-app:0.1
docker rmi node:lts
docker rmi $(docker images -aq) # remove remaining images
docker images
docker pull gcr.io/$PROJECT_ID/node-app:0.2
docker run -p 4000:80 -d gcr.io/$PROJECT_ID/node-app:0.2
curl http://localhost:4000


completed "Task 1"

completed "Lab"

remove_files 
