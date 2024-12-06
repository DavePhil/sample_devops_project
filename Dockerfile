FROM openjdk:17-alpine
WORKDIR /app
EXPOSE 8081
COPY target/sample_project.jar /app
CMD ["java","-jar","sample_project.jar"]


