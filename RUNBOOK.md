# Deploy


## Frontend
```
FROM node:14.17.4

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```
This dockerfile copies our project to the container, installs all the dependencies and sets the parameters for it to run
Сommand to create a container
```
 docker build -t class_schedule_frontend .
```
## Backend
```
FROM gradle:7.2-jdk11 AS build
WORKDIR /app
COPY . .
RUN gradle build -x test --no-daemon

FROM tomcat:9.0.50-jdk11-openjdk

USER root
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    apt-get clean

COPY --from=build /app/build/libs/class_schedule.war /usr/local/tomcat/webapps/ROOT.war


EXPOSE 8080

CMD ["catalina.sh", "run"]
```
This docker file builds our project and uploads it to the tomcat web server
Сommand to create a container
```
docker build -t class_schedule_frontend .
```
##DockerCompose
```
version: '3.8'

services:
  backend:
    image: class_schedule_backend
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
      - mongo

  frontend:
    image: class_schedule_frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

  postgres:
    image: postgres:14
    container_name: class_schedule_postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:latest
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  mongo:
    image: mongo:latest
    container_name: mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

volumes:
  postgres_data:
  mongo_data:
  redis_data:
```
With this docker compose file we run our entire project, 
it runs our frontend and backend containers that we created and 
runs the postgres caching redis database on the mongo database. 
This file is needed for all these components to work together
Command to run
```
docker-compose up -d
```
Command to stop
```
docker-compose down -v 
```
