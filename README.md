Node.js App with Nginx Load Balancer and Docker Compose
This project demonstrates how to deploy a simple Node.js application with Nginx acting as a load balancer. The app runs on three separate containers managed by Docker Compose, and Nginx load balances requests between them.

Project Structure
The project consists of the following files:

index.html: A simple HTML file that gets served by the Node.js application.
server.js: A basic Node.js server that serves the index.html file.
Dockerfile: The Dockerfile to containerize the Node.js application.
docker-compose.yml: The Docker Compose file that sets up multiple containers for the Node.js application and Nginx load balancer.
nginx.conf: Nginx configuration file to load balance requests to the Node.js containers.
Prerequisites
Docker: Make sure Docker is installed on your system. You can install Docker by following the instructions from the official Docker documentation.
Docker Compose: You also need Docker Compose installed. Install it from the Docker Compose documentation.
Setup and Installation
1. Clone the Repository
Clone the repository to your local machine:

bash
Copy code
git clone https://github.com/your-username/nodejs-nginx-loadbalancer.git
cd nodejs-nginx-loadbalancer
2. Review the Project Files
Ensure the following files exist and are configured correctly:

index.html: Contains the HTML content for the page served by the Node.js application.
html
Copy code
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Node.js Load Balancer</title>
</head>
<body>
    <h1>Welcome to Node.js Load Balancer</h1>
    <p>This request was served by one of the Node.js containers.</p>
</body>
</html>
server.js: A basic Node.js server that serves the index.html file.
javascript
Copy code
// server.js
const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
    if (req.url === '/') {
        fs.readFile(path.join(__dirname, 'index.html'), 'utf-8', (err, data) => {
            if (err) {
                res.writeHead(500);
                res.end('Error loading index.html');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data);
        });
    }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
Dockerfile: A Dockerfile to build the Node.js application container.
Dockerfile
Copy code
# Dockerfile for Node.js app
FROM node:16

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the port the app will run on
EXPOSE 3000

# Run the application
CMD ["node", "server.js"]
docker-compose.yml: The Docker Compose file to set up the containers for the Node.js app and the Nginx load balancer.
yaml
Copy code
version: '3.8'

services:
  nodejs1:
    build: .
    container_name: nodejs1
    environment:
      - PORT=3001
    ports:
      - "3001:3000"

  nodejs2:
    build: .
    container_name: nodejs2
    environment:
      - PORT=3002
    ports:
      - "3002:3000"

  nodejs3:
    build: .
    container_name: nodejs3
    environment:
      - PORT=3003
    ports:
      - "3003:3000"

  nginx:
    image: nginx:latest
    container_name: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "8080:80"
    depends_on:
      - nodejs1
      - nodejs2
      - nodejs3
nginx.conf: The Nginx configuration file to load balance requests across the Node.js containers.
nginx
Copy code
# nginx.conf

http {
    upstream node_js_cluster {
        server nodejs1:3000;
        server nodejs2:3000;
        server nodejs3:3000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://node_js_cluster;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
3. Build and Start the Containers with Docker Compose
Build the containers:
bash
Copy code
docker-compose build
Start the containers:
bash
Copy code
docker-compose up -d
This command will start the following containers:

3 Node.js containers (nodejs1, nodejs2, nodejs3) running the app on ports 3001, 3002, and 3003.
1 Nginx container acting as a load balancer, listening on port 8080 and proxying requests to the Node.js containers.
4. Access the Application
Once the containers are running, you can access the load-balanced Node.js application by visiting http://localhost:8080 in your browser.
Nginx will forward requests to one of the Node.js containers (nodejs1, nodejs2, or nodejs3), and you should see the same output regardless of which container handles the request.
5. Stopping the Containers
To stop the containers, run:

bash
Copy code
docker-compose down
6. Clean Up
If you want to remove all images and volumes, you can use the following command:

bash
Copy code
docker-compose down --volumes --rmi all
How It Works
Docker Compose is used to orchestrate the Node.js application containers and the Nginx load balancer.
Nginx acts as a reverse proxy and load balancer, distributing incoming requests across the three Node.js instances (nodejs1, nodejs2, nodejs3).
The Node.js containers serve a simple index.html file, and the load balancing is handled by Nginx based on the upstream configuration.
Troubleshooting
Container is not starting: Check the logs of a specific container with the following command:

bash
Copy code
docker logs <container-name>
Ports conflict: If port 8080 or 3001-3003 are already in use on your host, modify the docker-compose.yml file to use different ports.

License
This project is licensed under the MIT License - see the LICENSE file for details.

