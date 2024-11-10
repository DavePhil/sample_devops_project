FROM openjdk:17-alpine
EXPOSE 8081
ADD target/sample_project.jar sample_project.jar
ENTRYPOINT ["java","-jar","/sample_project.jar"]