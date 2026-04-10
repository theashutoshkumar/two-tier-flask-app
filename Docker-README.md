# Dockerfile (Flask App)
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir mysqlclient -r requirements.txt

COPY . .

CMD ["python", "app.py"]

# Build Docker Image
docker build -t flaskapp .

# Create Docker Network
docker network create two-tier

# Run MySQL Container

docker run -d \
  --name mysql \
  --network two-tier \
  -p 3306:3306 \
  -e MYSQL_DATABASE=myDb \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=admin \
  -e MYSQL_ROOT_PASSWORD=admin \
  mysql:5.7

  # Run Flask App Container

  docker run -d \
  --name flask-app \
  --network two-tier \
  -p 5000:5000 \
  -e MYSQL_HOST=mysql \
  -e MYSQL_USER=admin \
  -e MYSQL_PASSWORD=admin \
  -e MYSQL_DB=myDb \
  flaskapp:latest

  # Test Container Communication (DNS)

  docker exec -it flask-app ping mysql

  # Access MySQL Inside Container

  docker exec -it mysql bash

  # Run SQL Commands
  mysql -u root -p

  SHOW DATABASES;
  USE myDb;
  SHOW TABLES;
  SELECT * FROM messages;

  # Push Image to Docker Hub

  docker tag flaskapp:latest ashutoshkumarmahanta/flask-app:latest
  docker login
  docker push ashutoshkumarmahanta/flask-app:latest

  # docker-compose.yml

  version: '3'

services:
  backend:
    image: ashutoshkumarmahanta/flask-app:latest
    ports:
      - "5000:5000"
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin
      MYSQL_DB: myDb
    depends_on:
      mysql:
        condition: service_healthy

  mysql:
    image: mysql:5.7
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: myDb
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin
      MYSQL_ROOT_PASSWORD: admin
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uadmin", "-padmin"]
      interval: 10s
      timeout: 5s
      retries: 5
    volumes:
      - ./message.sql:/docker-entrypoint-initdb.d/message.sql
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:

  # Run with Docker Compose

  docker compose up -d
  docker ps
  docker compose down
