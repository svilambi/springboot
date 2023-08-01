From gcr.io/distroless/java17-debian11

# copy jar from the first stage
COPY build/libs/demo-0.0.1-SNAPSHOT.jar demo-0.0.1-SNAPSHOT.jar

EXPOSE 8888

CMD ["demo-0.0.1-SNAPSHOT.jar"]
