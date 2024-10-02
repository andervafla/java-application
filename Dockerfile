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