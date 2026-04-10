**Dockerfile (Flask App)**

# Use lightweight Python base image
FROM python:3.9-slim

# Set working directory inside container
WORKDIR /app

# Install required system dependencies (for mysqlclient)
RUN apt-get update \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir mysqlclient -r requirements.txt

# Copy application code
COPY . .

# Default command to run the Flask app
CMD ["python", "app.py"]

**Build Docker Image**

# NOTE: Build Docker image from Dockerfile
docker build -t flaskapp .

**Create Docker Network (IMPORTANT)**

# NOTE: Create custom network for communication between containers
docker network create two-tier


**Run MySQL Container**


# NOTE: Run MySQL container with environment variables
docker run -d \
  --name mysql \
  --network two-tier \   # NOTE: Attach to same network
  -p 3306:3306 \        # NOTE: Expose MySQL port
  -e MYSQL_DATABASE=myDb \     # NOTE: Create database
  -e MYSQL_USER=admin \        # NOTE: Create user
  -e MYSQL_PASSWORD=admin \    # NOTE: User password
  -e MYSQL_ROOT_PASSWORD=admin \ # NOTE: Root password
  mysql:5.7



**Run Flask App Container**


  # NOTE: Run Flask container and connect to MySQL
docker run -d \
  --name flask-app \
  --network two-tier \   # NOTE: Same network as MySQL
  -p 5000:5000 \        # NOTE: Expose Flask app
  -e MYSQL_HOST=mysql \ # NOTE: Use container name as hostname
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=admin \
  -e MYSQL_DB=myDb \
  flaskapp:latest

**Test Container Communication (DNS)**

  # NOTE: Check if Flask container can resolve MySQL hostname
docker exec -it flask-app ping mysql

**Access MySQL Inside Container**

# NOTE: Login to MySQL container
docker exec -it mysql bash


**Run SQL Commands**

# NOTE: Open MySQL CLI
mysql -u root -p

-- NOTE: Show all databases
SHOW DATABASES;

-- NOTE: Select database
USE myDb;

-- NOTE: Show tables
SHOW TABLES;

-- NOTE: Fetch data
SELECT * FROM messages;

**Push Image to Docker Hub**

# NOTE: Tag image for Docker Hub
docker tag flaskapp:latest ashutoshkumarmahanta/flask-app:latest

# NOTE: Login to Docker Hub
docker login

# NOTE: Push image
docker push ashutoshkumarmahanta/flask-app:latest


**docker-compose.yml (With Notes)**

version: '3'

services:
  backend:
    image: ashutoshkumarmahanta/flask-app:latest
    ports:
      - "5000:5000"   # NOTE: Expose Flask app
    environment:
      MYSQL_HOST: mysql   # NOTE: Service name acts as DNS
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin
      MYSQL_DB: myDb
    depends_on:
      mysql:
        condition: service_healthy  # NOTE: Wait until MySQL is ready

  mysql:
    image: mysql:5.7
    ports:
      - "3306:3306"  # NOTE: Expose DB port
    environment:
      MYSQL_DATABASE: myDb
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin
      MYSQL_ROOT_PASSWORD: admin
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uadmin", "-padmin"]
      interval: 10s
      timeout: 5s
      retries: 5   # NOTE: Retry until MySQL is healthy
    volumes:
      - ./message.sql:/docker-entrypoint-initdb.d/message.sql  # NOTE: Initialize DB
      - mysql-data:/var/lib/mysql  # NOTE: Persist data

volumes:
  mysql-data:  # NOTE: Named volume for MySQL persistence



**Run with Docker Compose**


  # NOTE: Start all services
docker compose up -d

# NOTE: Check running containers
docker ps

# NOTE: Stop services
docker compose down
