From openjdk:8-jre-alpine

# copy jar from the first stage
COPY --from=builder build/libs/demo-0.0.1-SNAPSHOT.jar demo-0.0.1-SNAPSHOT.jar

EXPOSE 8888

CMD ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar"]
