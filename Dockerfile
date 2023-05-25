From eclipse-temurin:17-jdk-alpine

# copy jar from the first stage
COPY build/libs/demo-0.0.1-SNAPSHOT.jar demo-0.0.1-SNAPSHOT.jar

EXPOSE 8888

CMD ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar"]
